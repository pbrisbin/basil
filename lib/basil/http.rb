module Basil
  # Handles simple and no-so-simple HTTP requests. If options is a Hash,
  # you must provide :host. Optionally, :path, :port, :user, and
  # :password can be specified. If options is not a Hash it is expected
  # to be a simple url (ex "http://google.com").
  #
  # Currently, https is used if :port is specified as 443 or a url is
  # passed that begins with "https". Basic authentication is used if
  # :username or :password is given.
  module HTTP
    class << self
      def get(options)
        logger.debug "GET"
        logger.debug options

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

            logger.debug req
            http.request(req)
          end
        else
          url = options
          require(url =~ /^https/ ? 'net/https' : 'net/http')

          logger.debug url
          Net::HTTP.get_response(URI.parse(url))
        end

        unless resp.is_a?(Net::HTTPOK)
          logger.warn 'Non-200 HTTP Response'
          logger.warn resp
        end

        resp
      end

      private

      def logger
        @logger ||= Loggers['http']
      end
    end
  end
end
