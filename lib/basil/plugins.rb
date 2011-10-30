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

    attr_reader :regex
    attr_accessor :description

    def initialize(type, regex)
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

    # create a message to no one from me from txt
    def says(txt)
      Message.new(nil, Config.me, txt)
    end

    # create a message to the sender of the message i'm currently
    # processing from me from txt
    def replies(txt)
      Message.new(@msg.from, Config.me, txt)
    end

    # forward the message i'm currently processing to new_to
    def forwards(new_to)
      Message.new(new_to, Config.me, @msg.text)
    end

    private_class_method :new

    def self.respond_to(regex, &block)
      p = new(:responder, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end

    def self.watch_for(regex, &block)
      p = new(:watcher, regex)
      p.define_singleton_method(:execute, &block)
      p.register!
    end

    def self.responders
      @responders ||= []
    end

    def self.watchers
      @@watchers ||= []
    end

    def self.load!(reload = false)
      dir = Config.plugins_directory

      if reload
        @@responders = []
        @@watchers   = []
      end

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
end
