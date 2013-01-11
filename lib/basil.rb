require 'forwardable'

Signal.trap('INT') { puts 'killed.'; exit 1 }

module Basil
  autoload :ChatHistory, 'basil/chat_history'
  autoload :Cli,         'basil/cli'
  autoload :Config,      'basil/config'
  autoload :Email,       'basil/email'
  autoload :HTTP,        'basil/http'
  autoload :Lock,        'basil/lock'
  autoload :Loggers,     'basil/loggers'
  autoload :Message,     'basil/message'
  autoload :Options,     'basil/options'
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
      options = Options.new
      options.parse(argv)

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
