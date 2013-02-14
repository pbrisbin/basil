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
            fork_worker

            break if once

            logger.debug "Sleeping thread for #{interval} seconds"

            sleep(interval)
          end
        end
      end

      def fork_worker
        pid = Process.fork do
          worker = Worker.new
          worker.run
        end

        logger.debug "Spawned worker with PID #{pid} to check mail"

        babysit(pid)

      rescue => ex
        logger.warn ex
      end

      # wait for our child, then kill them
      def babysit(pid)
        Timeout.timeout(30) do
          Process.wait(pid)
          logger.debug "Worker terminated. Status: #{$?.exitstatus}"
        end
      rescue Timeout::Error
        logger.warn "Killing worker with PID #{pid} (timeout)"
        logger.debug `kill -9 #{pid} 2>&1`
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
