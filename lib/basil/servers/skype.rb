require 'basil/skype'

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
      include Email
      include SkypeProxy

      def run

        check_email(30, JenkinsStrategy.new) do |obj,msg|
          begin
            each_chat do |chat|
              if obj.respond_to?(:send_to_chat?)
                get_chat_property(chat, 'topic') do |topic|
                  if topic && obj.send_to_chat?(topic)
                    send_message(chat, msg)
                  end
                end
              end
            end
          rescue Exception => ex
            $stderr.puts "#{ex}"
          end
        end

        on_message do |chat, msg|
          begin
            reply = Basil.dispatch(msg)
            send_message(chat, reply) if reply
          rescue Exception => ex
            chat.send_message("error: #{ex}")
          end
        end

        Thread.list.each(&:join)
      end
    end
  end
end
