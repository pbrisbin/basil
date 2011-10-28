module Basil
  def self.run
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

  class Server
    # Must be overriden by subclass. Block and wait for input, return a
    # Basil::Message when you receive one. The message will be processed
    # and listen will be called again.
    def self.listen; nil end

    # Must be overriden by subclass. When a reply is triggered, this
    # method will be called with it as its first and only argument.
    def self.puts; end
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
end

# A good server for local development; an interactive prompt.
class CliServer < Basil::Server
  class << self

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
