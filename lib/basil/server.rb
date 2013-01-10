module Basil
  class Server
    # Redefine your start method to be wrapped in a lock file, ensuring
    # no more than one instance of your server can be run at a time.
    def self.lock_start
      alias_method :original_start, :start

      define_method(:start) do
        Lock.guard do
          original_start
        end
      end
    end

    # Loads plugins and kicks off the email checking loop. Subclasses
    # should call super in their start method overrides.
    def start
      Plugin.load!
      Email.check if Config.server.respond_to?(:broadcast_message)

      main_loop
    end

    def main_loop
      raise NotImplementedError, "Server classes must implement #main_loop"
    end

    def dispatch_message(msg)
      unless msg && msg.text != ''
        raise ArgumentError, 'Nil or empty message dispatched'
      end

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
