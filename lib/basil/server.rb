module Basil
  class Server
    # Redefines +#start+ to be wrapped in a lock file, ensuring no more
    # than one instance of your server can be run at a time
    def self.lock_start
      alias_method :original_start, :start

      define_method(:start) do
        Lock.guard do
          original_start
        end
      end
    end

    def start
      Plugin.load!
      Email.check if respond_to?(:broadcast_message)

      main_loop do |*args|
        dispatch(*args)
      end
    end

    def main_loop
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    def build_message(*args)
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    private

    def dispatch(*args)
      msg = build_message(*args) or raise ArgumentError, 'nil message dispatched'

      ChatHistory.store_message(msg)

      logger.info "Dispatching #{msg}"

      Dispatch.process(msg).tap do |reply|
        logger.info "Reply #{reply}" if reply
      end

    rescue => ex
      logger.warn ex

      nil
    end

    def logger
      @logger ||= Loggers['server']
    end
  end
end
