require 'forwardable'

Signal.trap('INT') { puts 'killed.'; exit 1 }

module Basil
  autoload :ChatHistory,  'basil/chat_history'
  autoload :Cli,          'basil/cli'
  autoload :Config,       'basil/config'
  autoload :Daemon,       'basil/daemon'
  autoload :Dispatchable, 'basil/dispatchable'
  autoload :Email,        'basil/email'
  autoload :HTTP,         'basil/http'
  autoload :Lock,         'basil/lock'
  autoload :Loggers,      'basil/loggers'
  autoload :Message,      'basil/message'
  autoload :Options,      'basil/options'
  autoload :Plugin,       'basil/plugin'
  autoload :Server,       'basil/server'
  autoload :Skype,        'basil/skype'
  autoload :SkypeMessage, 'basil/skype_message'
  autoload :Storage,      'basil/storage'
  autoload :Timer,        'basil/timer'
  autoload :Utils,        'basil/utils'
  autoload :VERSION,      'basil/version'
  autoload :Worker,       'basil/worker'

  Loggers.init!

  class << self
    extend Forwardable
    delegate [:respond_to, :watch_for, :check_email] => Plugin

    def run(argv)
      options = Options.new
      options.parse(argv)

      Config.load!

      case argv.first
      when 'start'
        Daemon.start(false)
      when 'stop'
        Daemon.stop
      when 'restart'
        Daemon.stop
        Daemon.start(false)
      else
        Daemon.start
      end

    rescue => ex
      logger.fatal ex

      exit 1
    end

    def logger
      @logger ||= Loggers['main']
    end

  end
end
