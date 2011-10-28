module Basil
  def self.run
    load_plugins

    # any object that responds to listen and puts can be used
    server = Basil::Config.server

    while true
      msg = server.listen

      if msg && msg.to_me?
        Basil::Plugin.registered_plugins.each do |plugin|
          reply = plugin.reply(msg)
          server.puts reply if reply
        end
      end
    end
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

  module Servers
    class Cli
      def listen
        print '> '
        str = $stdin.gets.chomp
        str != '' ? Basil::Message.new('basil', 'me', str) : nil
      end

      def puts(msg)
        Kernel.puts msg
      end
    end
  end
end
