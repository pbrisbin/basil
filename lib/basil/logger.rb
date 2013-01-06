require 'delegate'
require 'log4r'

module Basil
  class Logger < SimpleDelegator

    def initialize(name)
      super init_logger(name)
    end

    private

    def init_logger(name)
      Log4r::Logger.new("basil::#{name}").tap do |logger|
        logger.level = Log4r::DEBUG if Config.debug?
      end
    end

  end
end
