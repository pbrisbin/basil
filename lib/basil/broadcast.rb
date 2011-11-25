require 'rack'
require 'rack/request'

module Basil
  class Broadcast
    class << self
      def run
        Thread.new do
          Rack::Server.new(:app  => rack_app,
                           :Port => Config.broadcast['port'].to_i,
                           :server => 'webrick').start
        end
      end

      def rack_app
        p = Proc.new do |env|
          begin
            req = Rack::Request.new(env)
            response = handle req.path_info, req.POST
            [200, {'Content-Type' => 'text/plain'}, [response]]
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
        case path
        when '/'
          "usage: curl --data-urlencode 'message=Some message' http://admin:secret@locahost:8080\n"
        when '/broadcast'
          "broadcasted #{params[:message]}\n"
        end
      end
    end
  end
end
