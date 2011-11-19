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

    def get_http(options)
      if options.is_a? Hash
        host     = options[:host]
        port     = options[:port]     rescue 80
        username = options[:user]     rescue nil
        password = options[:password] rescue nil
        path     = options[:path]

        secure = port == 443

        # An explicit cert file is needed if run on OSX, provided by the
        # curl-ca-bundle cert package
        cert_file = Config.https_cert_file rescue nil

        require (secure ? 'net/https' : 'net/http')
        net = Net::HTTP.new(host, port)

        if secure
          net.use_ssl = true
          net.ca_file = cert_file if cert_file
        end

        net.start do |http|
          req = Net::HTTP::Get.new(path)
          req.basic_auth(username, password) if username || password
          http.request(req)
        end
      else
        url = options
        require (url =~ /^https/ ? 'net/https' : 'net/http')
        Net::HTTP.get_response(URI.parse(url))
      end
    rescue Exception => ex
      $stderr.puts "error getting http: #{ex}"
      nil
    end

    def get_json(*args)
      require 'json'
      resp = get_http(*args)
      JSON.parse(resp.body) if resp
    rescue Exception => ex
      $stderr.puts "error parsing json: #{ex}"
      nil
    end

    def symbolize_keys(h)
      n = {}
      h.each do |k,v|
        n[k.to_sym] = v
      end

      n
    end
  end
end
