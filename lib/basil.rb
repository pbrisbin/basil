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
        Plugin.load!
        Email.check
        Config.server.start
        Thread.list.each(&:join)

      rescue Exception => ex
        $stderr.puts "#{ex}"
        $stderr.puts "#{ex.backtrace.join("\n")}"

        exit 1
      end

    end
  end
end
