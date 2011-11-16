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
            if reply = Basil.dispatch(msg)
              SkypeProxy.send_message(chat, reply)
            end
          rescue Exception => e
            chat.send_message("error: #{e.message}")
          end
        end

        Broadcast.on(:broadcast_received) do |msg|
          SkypeProxy.each_chat do |chat|
            puts '-*->>' + msg.inspect
            SkypeProxy.send_message(chat, msg)
          end
        end

        Thread.list.each(&:join)
      end
    end
  end
end
