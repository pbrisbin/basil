require 'forwardable'

module Basil
  autoload :ChatHistory, 'basil/chat_history'
  autoload :Cli,         'basil/cli'
  autoload :Config,      'basil/config'
  autoload :Dispatch,    'basil/dispatch'
  autoload :Email,       'basil/email'
  autoload :Lock,        'basil/lock'
  autoload :Logger ,     'basil/logger'
  autoload :Message,     'basil/message'
  autoload :Plugin,      'basil/plugin'
  autoload :Server,      'basil/server'
  autoload :Skype,       'basil/skype'
  autoload :Storage,     'basil/storage'
  autoload :Utils,       'basil/utils'

  class << self
    extend Forwardable
    delegate [:respond_to, :watch_for, :check_email] => Plugin

    def run(argv)
      if argv.include?('--debug')
        Config.debug = true
      end

      if argv.include?('--cli')
        Config.server = Cli.new
      end

      Config.server.start

    rescue => ex
      $stderr.puts "#{ex}"
      exit 1
    end
  end
end
