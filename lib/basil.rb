# libs
require 'forwardable'

# mixins
require 'basil/chat_history'
require 'basil/email'
require 'basil/utils'

# classes
require 'basil/server'
require 'basil/cli'
require 'basil/skype'
require 'basil/config'
require 'basil/dispatch'
require 'basil/message'
require 'basil/plugins'
require 'basil/storage'

module Basil
  class << self
    extend Forwardable

    def_delegator Basil::Plugin, :respond_to
    def_delegator Basil::Plugin, :watch_for
    def_delegator Basil::Plugin, :check_email
  end

  class Main
    attr_reader :server, :dispatcher

    def initialize(*args)
      @server     = Config.server(self)
      @dispatcher = Config.dispatcher(self)
    end

    def run
      Plugin.load!

      Email.check(server)

      server.start

      Thread.list.each(&:join)

    rescue Exception => ex
      $stderr.puts "#{ex}"
      $stderr.puts "#{ex.backtrace.join("\n")}"

      exit 1
    end

    def dispatch_message(msg)
      ChatHistory.store_message(msg)

      dispatcher.dispatch(msg)
    end

    def sending_message(msg)

    end
  end
end
