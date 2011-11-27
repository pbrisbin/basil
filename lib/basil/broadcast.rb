require 'rack'
require 'rack/request'

module Basil
  class Broadcast
    class << self
      def server
        @@server ||= Rack::Server.new(:app    => rack_app,
                                      :Port   => Config.broadcast['port'].to_i,
                                      :server => 'webrick')
      end

      def callbacks
        @@callbacks ||= []
      end

      private

      def rack_app
        p = Proc.new do |env|
          begin
            req = Rack::Request.new(env)
            response = handle req.path_info, req.POST
            [200, {'Content-Type' => 'text/plain'}, [response + "\n"]]
          rescue Exception => ex
            [500, {'Content-Type' => 'text/plain'}, ["error: #{ex}\n"]]
          end
        end

        user = Config.broadcast['user'] rescue nil
        pass = Config.broadcast['password'] rescue nil

        return p unless user && pass

        app = Rack::Auth::Basic.new(p) do |u, p|
          u == user && p == pass
        end

        app.realm = 'basil.the.bot 1.0'

        app
      end

      def handle(path, params)
        $stderr.puts "broadcasted #{path}, #{params.inspect}"

        raise 'invalid path or parameters'
      end
    end
  end
end
