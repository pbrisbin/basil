require 'forwardable'

# mixins
require 'basil/chat_history'
require 'basil/logging'
require 'basil/utils'

# base classes
require 'basil/server'

# classes
require 'basil/cli'
require 'basil/config'
require 'basil/dispatch'
require 'basil/email'
require 'basil/lock'
require 'basil/message'
require 'basil/plugins'
require 'basil/skype'
require 'basil/storage'

module Basil
  class << self
    extend Forwardable

    def_delegators Plugin, :respond_to, :watch_for, :check_email
  end

  class Main
    class << self
      include Logging

      def run!(args)
        while arg = args.shift
          case arg
          when '--debug'
            Logger.level = ::Logger::DEBUG
          when '--cli'
            Config.server = Cli.new
          end
        end

        Plugin.load!

        Email.check

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
end
