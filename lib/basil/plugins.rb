module Basil
  def self.load_plugins(dir = './plugins')
    Dir.glob(dir + '/*').each do |f|
      require f
    end
  end

  class Plugin
    # Must be overriden by subclass. return true if the plugin should
    # take action on the message. if you want to use any information
    # from the message, it should be stored in class variables at this
    # point.
    def self.match(msg); false end

    # Must be overriden be overriden by subclass. return a text reply
    # that should be send if match returns true.
    def self.reply; end

    @registered_plugins = []


    def self.register(klass)
      registered_plugins << klass
    end

    def self.registered_plugins
      @registered_plugins ||= []
    end
  end
end
