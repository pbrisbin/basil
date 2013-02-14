require 'net/imap'
require 'basil/email/mail'
require 'basil/email/checker'

module Basil
  module Email
    class << self

      attr_reader :thread

      def check
        interval = Config.email['interval'] || 30

        @thread = Timer.new(:sleep => interval) do
          logger.info "Checking email"

          Worker.new do
            checker = Checker.new
            checker.run
          end

          logger.info "Email check done"
        end
      end

      private

      def logger
        @logger ||= Loggers['email']
      end

    end
  end
end
