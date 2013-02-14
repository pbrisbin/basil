module Basil
  class Timer
    DEFAULT_SLEEP = 30

    def initialize(options = {})
      once         = options.fetch(:once, false)
      sleep_time   = options.fetch(:sleep,  DEFAULT_SLEEP)
      sleep_before = options.fetch(:sleep_before, 0)
      sleep_after  = options.fetch(:sleep_after, sleep_time)

      @thread = Thread.new do
        loop do
          sleep(sleep_before)

          yield if block_given?

          break if once

          sleep(sleep_after)
        end
      end
    end

    def method_missing(*args, &block)
      @thread.send(*args, &block)
    end

  end
end
