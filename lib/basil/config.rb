module Basil
  class Config
    class << self

      def me
        'basil'
      end

      def server
        CliServer
      end

    end
  end
end
