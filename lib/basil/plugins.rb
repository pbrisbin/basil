module Basil
  # The plugin class is used to encapsulate triggered actions. Plugin
  # writers must use respond_to or watch_for to create an intance of
  # Plugin with a singleton execute method.
  class Plugin
    include Basil
    include Basil::Utils

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

    def self.responders
      @@responders ||= []
    end

    def self.watchers
      @@watchers ||= []
    end

    def self.load!
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

    def initialize(type, regex)
      if regex.is_a? String
        regex = Regexp.new("^#{regex}$")
      end

      @type, @regex = type, regex
      @description  = nil
    end

    def triggered(msg)
      if msg.text =~ @regex
        @msg = msg
        @match_data = $~

        return execute
      end

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
