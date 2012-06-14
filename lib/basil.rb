require 'forwardable'

# mixins
require 'basil/chat_history'
require 'basil/utils'

# classes
require 'basil/server'
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
      def run!(args)
        server = Config.server(self)

        Plugin.load!
        Email.check(server)

        server.start

        Thread.list.each(&:join)

      rescue Exception => ex
        $stderr.puts "#{ex}"
        $stderr.puts "#{ex.backtrace.join("\n")}"

        exit 1
      end

      # called when the server has received an incoming message. returns
      # a reply (which the server should send) or nil.
      def dispatch_message(msg)
        ChatHistory.store_message(msg)

        if Config.dispatcher_type == :extended
          Dispatch.extended(msg)
        else
          Dispatch.simple(msg)
        end

      rescue Exception => ex
        # TODO: how to handle, send the error to channel? log and return
        # nil (letting other plugins have a chance)?
        $stderr.puts "Error dispatching #{msg.text}: #{ex}"

        nil
      end

      # called when the server is about to send any message for any
      # reason. return value doesn't matter.
      def sending_message(msg)

      end
    end
  end
end
