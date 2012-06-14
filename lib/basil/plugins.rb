module Basil
  # The plugin class is used to encapsulate triggered actions. Plugin
  # writers must use respond_to or watch_for to create an instance of
  # Plugin with a singleton execute method.
  class Plugin
    include Utils
    include ChatHistory

    attr_reader :regex
    attr_accessor :description

    private_class_method :new

    class << self
      # Create an instance of Plugin which will look for regex only in
      # messages that are to basil.
      def respond_to(regex, &block)
        p = new(:responder, regex)
        p.define_singleton_method(:execute, &block)
        p.register!
      end

      # Create an instance of Plugin which will look for regex in any
      # messages sent in the chat.
      def watch_for(regex, &block)
        p = new(:watcher, regex)
        p.define_singleton_method(:execute, &block)
        p.register!
      end

      # Register an object used for checking emails. See the Email
      # module's documentation and an example in the jenkins plugin.
      def check_email(obj)
        email_strategies << obj
      end

      def responders
        @responders ||= []
      end

      def watchers
        @watchers ||= []
      end

      def email_strategies
        @email_strategies ||= []
      end

      def load!
        dir = Config.plugins_directory

        if Dir.exists?(dir)
          Dir.glob(dir + '/*').sort.each do |f|
            begin load(f)
            rescue => e
              $stderr.puts "error loading #{f}: #{e.message}."
              next
            end
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

    def triggered(msg)
      if @regex.nil? || msg.text =~ @regex
        @msg = msg
        @match_data = $~

        return execute
      end

      nil

    rescue Exception => ex
      # TODO: how to handle this? let other plugins take a swing or
      # reply with the error?
      nil
    end

    def register!
      case @type
      when :responder; Plugin.responders << self
      when :watcher  ; Plugin.watchers   << self
      end; self
    end
  end
end
