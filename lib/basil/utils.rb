module Basil
  # as many generally useful uitility functions for plugins should be
  # located here
  module Utils
    def says(txt)
      Message.new(nil, Config.me, Config.me, txt)
    end

    def replies(txt)
      Message.new(@msg.from_name, Config.me, Config.me, txt)
    end

    def forwards_to(new_to)
      Message.new(new_to, Config.me, Config.me, @msg.text)
    end

    def require_authorization(level = nil) # to be implemented
      authorized_users = Config.authorized_users rescue []

      if authorized_users.include?(@msg.from)
        return yield
      else
        says "Sorry #{@msg.from_name}, I'm afraid I can't do that for you"
      end
    end

    def escape(str)
      require 'cgi'
      CGI::escape(str.strip)
    end

    #
    # get_json('http://example.com/some/path')
    # get_json('example.com', '/some/path', 8080 [, 'user', 'pass' ])
    #
    def get_json(host, path = nil, port = nil, username = nil, password = nil)
      require 'json'
      require 'net/http'

      resp = if path || port || username || password
               Net::HTTP.start(host, port) do |http|
                 req = Net::HTTP::Get.new(path)
                 req.basic_auth username, password
                 http.request(req)
               end
             else
               Net::HTTP.get_response(URI.parse(host))
             end

      JSON.parse(resp.body)
    rescue => e
      $stderr.puts e.message

      nil
    end
  end
end
