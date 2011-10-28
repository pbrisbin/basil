class TestPlugin < Basil::Plugin
  class << self
    def match(msg)
      msg.text =~ /^test$/
    end

    def reply
      'Hello World!'
    end
  end
end

Basil::Plugin.register(TestPlugin)
