module Basil
  class Broadcast
    def self.on(event, &block)
      Thread.new do
        loop do
          begin accept_message(event, &block)
          rescue Exception => e
            $stderr.puts e.message
          end
        end
      end
    end

    private

    # TODO: use an HTTP server with validation, GET/POST params, and
    # maybe even some admin routes. at that point, different types of
    # broadcasts can be handled
    def self.accept_message(event)
      require 'socket'

      @@tcp ||= TCPServer.new(Config.broadcast_host, Config.broadcast_port)

      con = @@tcp.accept
      msg = con.read

      yield Message.new(:all, nil, nil, msg) if msg && msg != ''
    end
  end
end
