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
        Basil::Servers::Cli.new
      end

################################################################################
    end
  end
end
