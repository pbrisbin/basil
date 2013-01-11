require 'log4r'

module Basil
  module Loggers
    LOGGER_NAMES = %w( main email server plugins dispatching http )

    class << self
      include Log4r

      def init!
        formatter = BasicFormatter.new
        outputter = StdoutOutputter.new('stdout', :formatter => formatter)

        Logger.global.level = INFO

        LOGGER_NAMES.each do |name|
          logger = Logger.new(name)
          logger.add(outputter)
        end
      end

      def [](name)
        # an invalid name returns the root logger (a NullObject)
        Logger[name] || Logger.global
      end

      def level=(level)
        Logger.each do |_,logger|
          logger.level = level
        end
      end

    end
  end
end
