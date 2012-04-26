require 'basil/skype'

module Basil
  module Server
    # A Skype bot implemented via a dbus connection to a running skype
    # client on the same machine. see: https://github.com/nfelger/rype
    class SkypeBot
      include Basil
      include Email
      include Skype

      def run
        check_email(30) do |trigger, msg|
          begin
            each_chat do |chat|
              chat.topic do |topic|
                send_message(chat, msg) if trigger.send_to_chat?(topic)
              end
            end
          rescue Exception => ex
            $stderr.puts "#{ex}"
          end
        end

        on_message do |chat, msg|
          begin
            reply = dispatch(msg)
            send_message(chat, reply) if reply
          rescue Exception => ex
            chat.send_message("error: #{ex}")
          end
        end

        Thread.list.each(&:join)
      end

      def dispatch(msg)
        if (Config.extended_readline rescue false)
          Readline.dispatch(msg)
        else
          Basil.dispatch(msg)
        end
      end
    end
  end
end
