require 'basil/utils'
require 'basil/plugins'
require 'basil/config'
require 'basil/servers/cli'
require 'basil/servers/skype'

module Basil
  def self.run
    Plugin.load!
    server = Config.server
    server.run
  end

  def listen_for_broadcasts
    return unless block_given?

    Thread.new do
      while true
        begin
          tcp ||= TCPServer.new(Config.broadcast_host, Config.broadcast_port)
          con = tcp.accept
          msg = con.read

          if msg && msg != ''
            yield Message.new(nil, nil, nil, msg)
          end

        rescue => e
          $stderr.puts e.message
        end
      end
    end
  end

  class Message
    include Basil

    attr_reader :to, :from, :from_name, :time, :text

    def initialize(to, from, from_name, text)
      @time = Time.now
      @to, @from, @from_name, @text = to, from, from_name, text
    end

    def to_me?
      to == Config.me
    end
  end
end
