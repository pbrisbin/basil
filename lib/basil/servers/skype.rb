module Basil
  module Server
    # A Skype bot implemented via a dbus connection to a running skype
    # client on the same machine.
    #
    # 1. Install skype
    # 2. Setup a profile for your bot
    # 3. Start skype and sign into that profile
    # 4. Install and test my fork of the skype gem
    # 5. Start basil using this server
    #
    class SkypeBot
      include Basil

      def run
        require 'basil/skype'

        SkypeProxy.on_message do |chat, msg|
          begin
            reply = Basil.dispatch(msg)
            SkypeProxy.send_message(chat, reply) if reply
          rescue Exception => ex
            chat.send_message("error: #{ex}")
          end
        end

        Thread.list.each(&:join)
      end
    end
  end
end
