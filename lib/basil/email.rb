module Basil
  module Email
    autoload :Checker, 'basil/email/checker'
    autoload :Mail,    'basil/email/mail'

    class << self

      attr_reader :thread

      def check
        interval = Config.email['interval'] || 30

        @thread = Timer.new(:sleep => interval) do
          Worker.new do
            checker = Checker.new
            checker.run
          end
        end
      end

    end
  end
end
