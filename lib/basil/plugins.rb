module Basil
  def dispatch(msg)
    return nil unless msg && msg != ''

    if msg.to_me?
      Plugin.responders.each do |p|
        reply = p.triggered(msg)
        return reply if reply
      end
    end

    Plugin.watchers.each do |p|
      reply = p.triggered(msg)
      return reply if reply
    end

    nil
  end

  class Plugin
    include Basil
    include Basil::Utils

    attr_reader :regex
    attr_accessor :description

    # respond_to and watch_for are the only ways to instantiate a Plugin
    private_class_method :new

    # if a message is "to me" and contains regex, block will be executed
    # to form a reply Message to send
    def self.respond_to(regex, &block)
      p = new(:responder, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end

    # if regex is seen in any message in the chat, block will be
    # executed to form a Message to send
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

    # if a plugin wants to act on msg, this method will return the reply
    # Message; otherwise, nil
    def triggered(msg)
      if msg.text =~ @regex
        @msg = msg
        @match_data = $~

        return execute
      end

      nil
    end

    # a plugin can register itself as a responder or watcher, it will be
    # consulted for a reply (first-come-first-server) on any messages
    def register!
      case @type
      when :responder; Plugin.responders << self
      when :watcher  ; Plugin.watchers   << self
      end; self
    end
  end
end
