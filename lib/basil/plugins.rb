module Basil
  def self.load_plugins
    dir = Basil::Config.plugins_directory
    if Dir.exists?(dir)
      Dir.glob(dir + '/*').each do |f|
        begin require f
        rescue => e
          $stderr.puts "#{f}: error: #{e.message}.", "Skipping..."
          next
        end
      end
    end
  end

  class Plugin
    attr_reader :type, :msg, :match_data
    attr_writer :regex, :action

    def initialize(type)
      @type = type
    end

    def triggers_on?(msg)
      msg.text =~ @regex
    end

    def act_on(msg)
      @msg = msg
      @action.call(self)
    end

    # create a message to no one from me from txt
    def says(txt)
      Basil::Message.new(nil, Basil::Config.me, txt)
    end

    # create a message to the sender of the message i'm currently
    # processing from me from txt
    def replies(txt)
      Basil::Message.new(msg.from, Basil::Config.me, txt)
    end

    # forward the message i'm currently processing to new_to
    def forwards(new_to)
      Basil::Message.new(new_to, Basil::Config.me, msg.text)
    end

    private_class_method :new

    def self.respond_to(regex, &block)
      p = new(:responder)
      p.regex  = regex
      p.action = block

      Plugin.register(p)
    end

    def self.watch_for(regex, &block)
      p = new(:watcher)
      p.regex  = regex
      p.action = block

      Plugin.register(p)
    end

    def self.plugin_for(msg)
      if msg.to_me?
        responders.each do |p|
          return p if p.triggers_on?(msg)
        end
      end

      watchers.each do |p|
        return p if p.triggers_on?(msg)
      end

      nil
    end
    
    private

    def self.responders
      @responders ||= []
    end

    def self.watchers
      @@watchers ||= []
    end

    def self.register(p)
      case p.type
      when :responder; responders << p
      when :watcher  ; watchers   << p
      end; p
    end
  end
end
