module Basil
  # The plugin class is used to encapsulate triggered actions. Plugin
  # writers must use respond_to or watch_for to create an instance of
  # Plugin with a singleton execute method.
  class Plugin
    include Utils

    private_class_method :new

    # Create an instance of Plugin which will look for regex only in
    # messages that are to basil.
    def self.respond_to(regex, &block)
      new(:responder, regex, &block)
    end

    # Create an instance of Plugin which will look for regex in any
    # messages sent in the chat.
    def self.watch_for(regex, &block)
      new(:watcher, regex, &block)
    end

    # Create an instance of Plugin which will look for regex in the
    # subject of any emails basil receives.
    def self.check_email(regex, &block)
      new(:email_checker, regex, &block)
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
        Dir.glob("#{dir}/*").sort.each do |f|
          begin load(f)
          rescue Exception => ex
            logger.warn ex
            next
          end
        end
      end
    end

    def self.logger
      @logger ||= Loggers['plugins']
    end

    attr_reader :type, :regex
    attr_accessor :description

    def initialize(type, regex, &block)
      @type  = type
      @regex = regex.is_a?(String) ? Regexp.new("^#{regex}$") : regex

      define_singleton_method(:execute, &block)

      case type
      when :responder    ; Plugin.responders     << self
      when :watcher      ; Plugin.watchers       << self
      when :email_checker; Plugin.email_checkers << self
      end
    end

    # if the message's text matches our regex, set the proper instance
    # variables and call our execute method.
    def triggered?(msg)
      if type == :email_checker
        matcher = ->(m) { regex.nil? || m['Subject'] =~ regex }
        coercer = ->(m) { Message.new(:to => Config.me, :from => m['From'], :text => m.body) }
      else
        matcher = ->(m) { regex.nil? || m.text =~ regex }
      end

      if matcher.call(msg)
        @msg = coercer ? coercer.call(msg) : msg
        @match_data = $~

        return execute
      end

      nil
    end

    def inspect
      "#<Plugin type: #{type}, regex: #{regex.inspect}, description: #{description.inspect}>"
    end

    def logger
      self.class.logger
    end
  end
end
