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
      def get(options)
        logger.debug "GET"
        log_options(options)

        resp = case options
               when Hash   then complex_get(options)
               when String then simple_get(options)
               else raise ArgumentError, "get method accepts only Hash or String"
               end

        unless resp.is_a?(Net::HTTPOK)
          logger.warn 'Non-200 HTTP Response'
          logger.warn resp
        end

        resp
      end

      private

      def simple_get(url)
        require_net_http(url =~ /^https/)

        Net::HTTP.get_response(URI.parse(url))
      end

      def complex_get(options)
        host     = options.fetch('host') { raise ArgumentError, "options['host'] is required" }
        port     = options.fetch('port', 80)
        path     = options.fetch('path', '/')
        username = options['user']
        password = options['password']
        secure   = port == 443

        require_net_http(secure)

        net = Net::HTTP.new(host, port)

        if secure
          net.use_ssl = true
          net.ca_file = Config.https_cert_file # OSX fix
        end

        net.start do |http|
          req = Net::HTTP::Get.new(path)
          req.basic_auth(username, password) if username || password

          http.request(req)
        end
      end

      def require_net_http(secure)
        require(secure ? 'net/https' : 'net/http')
      end

      def log_options(options)
        if options.is_a?(Hash) && options.has_key?('password')
          logger.debug options.merge('password' => 'xxx')
        else
          logger.debug options
        end
      end

      def logger
        @logger ||= Loggers['http']
      end
    end
  end
end
