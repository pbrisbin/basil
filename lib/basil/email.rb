require 'net/imap'
require 'basil/email/mail'
require 'basil/email/worker'

module Basil
  module Email
    class << self

      attr_reader :thread

      def check(once = false)
        @thread = spawn_timer_thread(once)

        logger.info "Spawned email monitor #{thread}"
      end

      private

      def spawn_timer_thread(once)
        Thread.new do
          loop do
            pid = fork_worker

            logger.debug "Spawned worker with PID #{pid} to check mail"

            break if once

            logger.debug "Sleeping thread for #{interval} seconds"

            sleep(interval)
          end
        end
      end

      def fork_worker
        fork do
          worker = Worker.new
          worker.run
        end
      end

      def interval
        Config.email['interval'] || 30
      end

      def logger
        @logger ||= Loggers['email']
      end

    end
  end
end
