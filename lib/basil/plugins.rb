module Basil
  def self.load_plugins(dir = './plugins')
    Dir.glob(dir + '/*').each do |f|
      require f
    end
  end

  class Plugin
    def initialize(regex, &block)
      @matcher = lambda { |msg| msg.text =~ regex }
      @block   = block
    end

    def reply(msg)
      if @matcher.call(msg)
        return @block.call(msg)
      end

      nil
    end

    private_class_method :new

    def self.answer(regex, &block)
      p = new(regex, &block)
      Plugin.register(p)
    end

    @@registered_plugins = []

    def self.registered_plugins
      @@registered_plugins ||= []
    end

    private

    def self.register(instance)
      registered_plugins << instance
    end
  end
end
