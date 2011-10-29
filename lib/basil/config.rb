module Basil
  class Config
    class << self
################################################################################

      # nick used to identify messages to me
      def me
        'basil'
      end

      # instance of server to run
      def server
        Basil::Server::Cli.new
      end

      # directory holding plugin files
      def plugins_directory
        './plugins'
      end

################################################################################
    end
  end
end
