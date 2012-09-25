require 'forwardable'
require 'logger'

module Basil
  module Logging
    LOG_METHODS = [ :fatal, :error, :warn, :info, :debug ]

    # when we're included, define delegators for use in both class and
    # instance methods
    def self.included(base)
      base.extend(Forwardable)
      base.def_delegators Logger, *LOG_METHODS

      base.class_eval do
        class << self
          extend(Forwardable)
          def_delegators Logger, *LOG_METHODS
        end
      end
    end
  end

  class Logger
    class << self
      def method_missing(*args, &block)
        logger.send(*args, &block)
      end

      private

      def logger
        @logger ||= ::Logger.new(STDERR).tap do |logger|
          logger.level = ::Logger::INFO
        end
      end
    end
  end
end
