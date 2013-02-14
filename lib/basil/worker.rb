module Basil
  class Worker
    TIMEOUT = 30

    attr_reader :pid, :exitstatus

    def initialize(&block)
      @pid = Process.fork(&block)

      logger.debug "#{pid}: spawned"

      t = monitor(pid)

      Process.wait(pid)
      @exitstatus = $?.exitstatus

      logger.debug "#{pid}: exited (status: #{exitstatus})"

      t.exit if t.alive?
    end

    private

    def monitor(pid)
      options = {
        :once => true,
        :sleep_before => TIMEOUT
      }

      Timer.new(options) do
        logger.warn "#{pid}: timed out"
        system("kill -9 #{pid}")
        logger.debug "#{pid}: killed"
      end
    end

    def logger
      @logger ||= Loggers['workers']
    end

  end
end
