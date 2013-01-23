module Basil
  module HTTP
    class << self
      #
      #   get(url) OR
      #
      #   get(options)
      #     options['host'] - required
      #     options['port'] - optional, defaults to 80
      #     options['path'] - optional, defaults to /
      #     options['username'] - optional
      #     options['password'] - optional
      #
      # This method handles mostly params sanitization and logging, with
      # the heavy lifting done by a Request instance.
      #
      def get(options)
        if options.is_a?(String) # simple url
          options = from_url(options)
        end

        logger.debug 'GET'
        logger.debug mask(options)

        request  = Request.new(options)
        response = request.get

        unless response.is_a?(Net::HTTPOK)
          logger.warn 'Non-200 HTTP Response'
          logger.warn response
        end

        response
      end

      private

      def from_url(url)
        uri = URI.parse(url)

        {}.tap do |options|
          options['host'] = uri.host
          options['port'] = uri.port
          options['path'] = uri.path
          options['path'] << "?#{uri.query}" if uri.query
        end
      end

      def mask(options)
        if options.has_key?('password')
          options.merge('password' => 'xxx')
        else
          options
        end
      end

      def logger
        @logger ||= Loggers['http']
      end
    end

    class Request
      def initialize(options)
        @host = options.fetch('host') { raise ArgumentError, "options['host'] is required" }
        @port = options.fetch('port', 80)
        @username = options['user']
        @password = options['password']

        # surprisingly, URI.parse can give you an empty path which is
        # not valid for Net::HTTP. sigh.
        @path = options['path']
        @path = '/' if path.nil? || path.empty?
      end

      def get
        require(secure? ? 'net/https' : 'net/http')

        net = Net::HTTP.new(host, port)

        if secure?
          net.use_ssl = true
          net.ca_file = Config.https_cert_file # OSX fix
        end

        net.start do |http|
          req = Net::HTTP::Get.new(path)
          req.basic_auth(username, password) if authenticate?

          http.request(req)
        end
      end

      def secure?
        port == 443
      end

      private

      attr_reader :host, :port, :path, :username, :password

      def authenticate?
        !!( username || password )
      end
    end
  end
end
