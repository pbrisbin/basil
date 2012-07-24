module Basil
  # The plugin class is used to encapsulate triggered actions. Plugin
  # writers must use respond_to or watch_for to create an instance of
  # Plugin with a singleton execute method.
  class Plugin
    include Utils
    include ChatHistory
    include Logging

    class << self
      # so we have log methods in class methods
      include Logging
    end

    private_class_method :new

    def self.create(type, regex, &block)
      p = new(type, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end
    private_class_method :create

    # Create an instance of Plugin which will look for regex only in
    # messages that are to basil.
    def self.respond_to(regex, &block)
      create(:responder, regex, &block)
    end

    # Create an instance of Plugin which will look for regex in any
    # messages sent in the chat.
    def self.watch_for(regex, &block)
      create(:watcher, regex, &block)
    end

    # Create an instance of Plugin which will look for regex in the
    # subject of any emails basil receives.
    def self.check_email(regex, &block)
      create(:email_checker, regex, &block)
    end

    def self.responders
      @responders ||= []
    end

    def self.watchers
      @watchers ||= []
    end

    def self.email_checkers
      @email_checkers ||= []
    end

    def self.load!
      dir = Config.plugins_directory

      if Dir.exists?(dir)
        debug "loading plugins from #{dir}"

        Dir.glob("#{dir}/*").sort.each do |f|
          begin load(f)
          rescue Exception => ex
            error "loading plugin #{f}: #{ex}"
            next
          end
        end
      end
    end

    attr_reader :type, :regex
    attr_accessor :description

    def initialize(type, regex)
      if regex.is_a? String
        regex = Regexp.new("^#{regex}$")
      end

      @type, @regex = type, regex
      @description  = nil
    end

    # if the message's text matches our regex, set the proper instance
    # variables and call our execute method.
    def triggered?(msg)
      if type == :email_checker
        matcher = ->(m) { regex.nil? || msg['Subject'] =~ regex }
        coercer = ->(m) { Message.new(Config.me, msg['From'], msg['From'], msg.body, nil) }
      else
        matcher = ->(m) { regex.nil? || msg.text =~ regex }
      end

      if matcher.call(msg)
        @msg = coercer ? coercer.call(msg) : msg
        @match_data = $~

        return execute
      end

      nil
    end

    def register!
      case @type
      when :responder    ; Plugin.responders     << self
      when :watcher      ; Plugin.watchers       << self
      when :email_checker; Plugin.email_checkers << self
      end; self
    end

    # avoiding #to_s to preserve #inspect, see
    # http://bugs.ruby-lang.org/issues/4453.
    def pretty
      "#{@type}: #{@regex.inspect}"
    end
  end
end
