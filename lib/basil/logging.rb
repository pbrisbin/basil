require 'forwardable'
require 'logger'

module Basil
  module Logging
    def self.included(base)
      base.extend(Forwardable)
      base.def_delegators Logger, :fatal,
                                  :error,
                                  :warn,
                                  :info,
                                  :debug
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
