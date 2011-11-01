module Basil
  class Config
    include Basil
    class << self
################################################################################

      # nick used to identify messages to me
      def me
        @@me ||= 'basil'
      end

      # instance of server to run
      def server
        #@@server ||= Server::Cli.new
        @@server ||= Server::SkypeBot.new
      end

      # directory holding plugin files
      def plugins_directory
        @@plugins_directory ||= './plugins'
      end

      def authorized_users
        @@authorized_users ||= ['dave', 'patrick.brisbin']
      end

      def broadcast_host
        @@broadcast_host ||= '127.0.0.1'
      end

      def broadcast_port
        @@broadcast_port ||= 1234
      end

################################################################################
    end
  end
end
