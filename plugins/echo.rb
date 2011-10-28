class EchoPlugin < Basil::Plugin
  class << self
    def match(msg)
      if msg.text =~ /^echo (.*)/
        @@say = $1
        return true
      end

      false
    end

    def reply
      @@say
    end
  end
end

Basil::Plugin.register(EchoPlugin)
