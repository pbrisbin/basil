module Basil
  def self.run
    load_plugins

    # any object that responds to listen and puts can be used
    server = Basil::Config.server

    @@running = true

    while @@running
      msg = plugin = reply = nil

      msg    = server.listen
      plugin = Basil::Plugin.plugin_for(msg)
      reply  = plugin.execute rescue nil
      server.puts reply if reply
    end

    exit 0
  end

  def self.shutdown
    # todo, any cleanup?
    @@running = false
  end

  class Message
    attr_reader :to, :from, :time, :text

    def initialize(to, from, text)
      @time = Time.now
      @to, @from, @text = to, from, text
    end

    def to_me?
      to == Basil::Config.me
    end
  end

  module Server
    class Cli
      def listen
        print '> '
        str = $stdin.gets.chomp

        Basil.shutdown if str == 'quit'

        str != '' ? Basil::Message.new(Basil::Config.me, 'user', str) : nil
      end

      def puts(msg)
        Kernel.puts msg.text
      end
    end
  end
end
