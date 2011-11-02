module Basil
  class Config
    include Basil
    class << self
################################################################################

      def me
        @@me ||= 'basil'
      end

      def server
        #@@server ||= Server::Cli.new
        @@server ||= Server::SkypeBot.new
      end

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
