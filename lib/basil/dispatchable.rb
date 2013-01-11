module Basil
  module Dispatchable
    def dispatch(server)
      msg = to_message

      # we must store message before setting server, something about the
      # Skype object doesn't agree with PStore
      ChatHistory.store_message(msg) unless msg.chat.nil?

      msg.server = server

      logger.debug "Dispatching #{msg}"
      each_plugin do |plugin|
        begin
          if match_data = match?(plugin)
            logger.debug "Executing #{plugin}"
            plugin.set_context(msg, match_data)
            plugin.execute
          end
        rescue => ex
          logger.warn ex
        end
      end
    end

    def match?(plugin)
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    def each_plugin(&block)
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    def to_message
      raise NotImplementedError, "#{self.class} must implement #{__method__}"
    end

    private

    def logger
      @logger ||= Loggers['dispatching']
    end

  end
end
