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

      main_loop do |*args|
        msg = accept_message(*args)
        msg.dispatch(self)
      end
    end

    def main_loop
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    def accept_message(*args)
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    def send_message(msg)
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    private

    def logger
      @logger ||= Loggers['server']
    end
  end
end
