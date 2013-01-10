require 'forwardable'

module Basil
  autoload :ChatHistory, 'basil/chat_history'
  autoload :Cli,         'basil/cli'
  autoload :Config,      'basil/config'
  autoload :Dispatch,    'basil/dispatch'
  autoload :Email,       'basil/email'
  autoload :HTTP,        'basil/http'
  autoload :Lock,        'basil/lock'
  autoload :Loggers,     'basil/loggers'
  autoload :Message,     'basil/message'
  autoload :Plugin,      'basil/plugin'
  autoload :Server,      'basil/server'
  autoload :Skype,       'basil/skype'
  autoload :Storage,     'basil/storage'
  autoload :Utils,       'basil/utils'
  autoload :VERSION,     'basil/version'

  Loggers.init!

  class << self
    extend Forwardable
    delegate [:respond_to, :watch_for, :check_email] => Plugin

    def run(argv)
      if argv.include?('--debug')
        Loggers.level = 0 # DEBUG
      end

      logger.debug "Basil #{VERSION}"

      if argv.include?('--cli')
        Config.server = Cli.new
      end

      Config.server.start

    rescue => ex
      logger.fatal ex

      exit 1
    end

    def logger
      @logger ||= Loggers['main']
    end

  end
end
