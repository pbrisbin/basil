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

    attr_reader :regex
    attr_accessor :description

    private_class_method :new

    # Create an instance of Plugin which will look for regex only in
    # messages that are to basil.
    def self.respond_to(regex, &block)
      p = new(:responder, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end

    # Create an instance of Plugin which will look for regex in any
    # messages sent in the chat.
    def self.watch_for(regex, &block)
      p = new(:watcher, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end

    # Create an instance of Plugin which will look for regex in the
    # subject of any emails basil receives.
    def self.check_email(regex, &block)
      p = new(:email_checker, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
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
      if @regex.nil? || msg.text =~ @regex
        @msg, @match_data = msg, $~

        return execute
      end

      nil
    end

    # if the mail's sbject matches our regex, set the proper instance
    # variables and call our execute method.
    def email_triggered?(mail)
      if @regex.nil? || mail['Subject'] =~ @regex
        @match_data = $~
        @msg = Message.new(Config.me, mail['From'], mail['From'], mail.body, nil)

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
