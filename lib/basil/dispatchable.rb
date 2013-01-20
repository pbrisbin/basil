module Basil
  module Dispatchable
    def dispatch
      ChatHistory.store(self)

      logger.debug "Dispatching #{self}"

      each_plugin do |plugin|
        if match_data = match?(plugin)
          logger.debug "Executing #{plugin} (matched: #{match_data})"
          plugin.execute_on(self, match_data)
        end
      end
    rescue => ex
      logger.warn ex
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
