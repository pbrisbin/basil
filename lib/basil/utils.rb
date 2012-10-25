module Basil
  # Utility functions that are useful across multiple plugins should
  # reside here. They are mixed into the Plugin class. Functions here,
  # and plugins in general, should avoid rescuing errors -- let them
  # bubble up to be handled appropriately by the dispatcher.
  module Utils
    # Handles both single and multi-line statements to no one in
    # particular.
    #
    #   says "something"
    #
    #   says do |out|
    #     out << "first line"
    #     out << "second line"
    #   end
    #
    # The two invocation styles can be combined to do a sort of Header
    # and Lines thing when printing tabular data; the first argument
    # will be the first line printed then the rest will be built from
    # your block.
    #
    #   says "here's some data:" do |out|
    #     data.each do |d|
    #       out << d.to_s
    #     end
    #   end
    #
    def says(txt = nil, &block)
      if block_given?
        out = txt.nil? ? [] : [txt]

        yield out

        return says(out.join("\n")) unless out.empty?
      elsif txt
        return Message.new(nil, Config.me, Config.me, txt, @msg.chat)
      end

      nil
    end

    # Same usage and behavior as says but this will direct the message
    # back to the person who sent the triggering message.
    def replies(txt = nil, &block)
      if block_given?
        out = txt.nil? ? [] : [txt]

        yield out

        return replies(out.join("\n")) unless out.empty?
      elsif txt
        return Message.new(@msg.from_name, Config.me, Config.me, txt, @msg.chat)
      end

      nil
    end

    def forwards_to(new_to)
      Message.new(new_to, Config.me, Config.me, @msg.text, @msg.chat)
    end

    # Set the chat attribute of the underlying message. This allows
    # broadcasters to define what chat they're broadcasting to.
    # Eventually, maybe we'll allow cross-chat communication via basil.
    def set_chat(chat)
      @msg.chat = chat if @msg
    end

    def escape(str)
      require 'cgi'
      CGI::escape(str.strip)
    end

    # Handles simple and no-so-simple HTTP requests. If options is a
    # Hash, you must provide :host. Optionally, :path, :port, :user, and
    # :password can be specified. If options is not a Hash it is
    # expected to be a simple url (ex "http://google.com").
    #
    # Currently, https is used if :port is specified as 443 or a url
    # is passed that begins with "https". Basic authentication is used
    # if :username or :password is given.
    def get_http(options)
      Logger.debug("getting http: #{options.inspect}")

      resp = if options.is_a? Hash
        host     = options['host']
        port     = options['port'] || 80
        path     = options['path'] || '/'
        username = options['user']     # may be nil
        password = options['password'] # may be nil
        secure   = port == 443

        require(secure ? 'net/https' : 'net/http')
        net = Net::HTTP.new(host, port)

        if secure
          net.use_ssl = true

          # An explicit cert file is needed if run on OSX, provided by the
          # curl-ca-bundle cert package. value might be nil
          net.ca_file = Config.https_cert_file #if Config.https_cert_file
        end

        net.start do |http|
          req = Net::HTTP::Get.new(path)
          req.basic_auth(username, password) if username || password
          http.request(req)
        end
      else
        url = options
        require(url =~ /^https/ ? 'net/https' : 'net/http')
        Net::HTTP.get_response(URI.parse(url))
      end

      unless resp.is_a?(Net::HTTPOK)
        Logger.warn("Non-200 HTTP response: #{resp}")
      end

      resp
    end

    # Pass-through to get_http but yields to the block for conversion
    # (see get_json, xml or html for uses).
    def parse_http(*args, &block)
      resp = get_http(*args)
      yield resp.body if resp
    end

    def get_json(*args)
      require 'json'
      parse_http(*args) { |b| JSON.parse(b) }
    end

    def get_xml(*args)
      require 'faster_xml_simple'
      parse_http(*args) { |b| FasterXmlSimple.xml_in(b) }
    end

    def get_html(*args)
      require 'nokogiri'
      parse_http(*args) { |b| Nokogiri::HTML.parse(b) }
    end
  end
end
