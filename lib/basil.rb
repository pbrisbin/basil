require 'forwardable'

module Basil
  autoload :ChatHistory, 'basil/chat_history'
  autoload :Cli,         'basil/cli'
  autoload :Config,      'basil/config'
  autoload :Dispatch,    'basil/dispatch'
  autoload :Email,       'basil/email'
  autoload :Lock,        'basil/lock'
  autoload :Logging,     'basil/logging'
  autoload :Message,     'basil/message'
  autoload :Plugin,      'basil/plugin'
  autoload :Server,      'basil/server'
  autoload :Skype,       'basil/skype'
  autoload :Storage,     'basil/storage'
  autoload :Utils,       'basil/utils'

  include Logging

  class << self
    extend Forwardable
    def_delegators Plugin, :respond_to,
                           :watch_for,
                           :check_email

    def run(argv)
      if argv.include?('--debug')
        Logger.level = ::Logger::DEBUG
      end

      if argv.include?('--cli')
        Config.server = Cli.new
      end

      Config.server.start

    rescue => ex
      fatal "#{ex}"

      ex.backtrace.map do |line|
        debug "#{line}"
      end

      exit 1
    end
  end
end
