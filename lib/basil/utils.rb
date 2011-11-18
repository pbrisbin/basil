module Basil
  # Utility functions that are useful across multiple plugins should
  # reside here. They are mixed into the Plugin class.
  module Utils
    def says(txt)
      Message.new(nil, Config.me, Config.me, txt)
    end

    # Build an array of lines (with optional first line title) then send
    # it as a single multiline message.
    def says_multiline(title = nil)
      out = title.nil? ? [] : [title]

      yield out

      return says(out.join("\n")) unless out.empty?

      nil
    end

    def replies(txt)
      Message.new(@msg.from_name, Config.me, Config.me, txt)
    end

    def replies_multiline(title = nil)
      out = title.nil? ? [] : [title]

      yield out

      return replies(out.join("\n")) unless out.empty?

      nil
    end

    def forwards_to(new_to)
      Message.new(new_to, Config.me, Config.me, @msg.text)
    end

    def escape(str)
      require 'cgi'
      CGI::escape(str.strip)
    end

    # Make a simple or not-so simple request for json. Supports basic
    # auth and SSL. Prints to stderr and returns nil in case of errors.
    #
    #   get_json('http://example.com/some/path')
    #   get_json('example.com', '/some/path', 443, 'user', 'pass', true)
    #
    def get_json(host, path = nil, port = nil, username = nil, password = nil, secure = false)
      require 'json'

      if secure
        require 'net/https'
      else
        require 'net/http'
      end

      # An explicit cert file is needed if run on OSX, provided by the
      # curl-ca-bundle cert package
      cert_file = Config.https_cert_file rescue nil

      resp = if path || port || username || password
               net = Net::HTTP.new(host, port || 80)
               net.use_ssl = secure
               net.ca_file = cert_file if cert_file
               net.start do |http|
                 req = Net::HTTP::Get.new(path)
                 req.basic_auth username, password
                 http.request(req)
               end
             else
               Net::HTTP.get_response(URI.parse(host))
             end

      JSON.parse(resp.body)
    rescue Exception => e
      $stderr.puts e.message

      nil
    end
  end
end
