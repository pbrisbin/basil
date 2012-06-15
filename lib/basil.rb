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
require 'basil/message'
require 'basil/plugins'
require 'basil/skype'
require 'basil/storage'

module Basil
  class << self
    extend Forwardable

    def_delegator Basil::Plugin, :respond_to
    def_delegator Basil::Plugin, :watch_for
    def_delegator Basil::Plugin, :check_email
  end

  class Main
    class << self
      include Logging

      def run!(args)
        debug "starting up"

        Plugin.load!
        Email.check
        Config.server.start
        Thread.list.each(&:join)

      rescue Exception => ex
        fatal "#{ex}"

        debug "trace:"
        ex.backtrace.map do |line|
          debug "  #{line}"
        end

        exit 1
      end
    end
  end
end
