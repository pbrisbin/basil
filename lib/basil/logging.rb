require 'forwardable'
require 'logger'
require 'singleton'

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
    include Singleton

    def self.method_missing(meth, *args, &block)
      self.instance.send(meth, *args, &block)
    end

    def method_missing(meth, *args, &block)
      @logger.send(meth, *args, &block)
    end

    def initialize
      @logger = ::Logger.new(STDERR)
    end
  end
end
