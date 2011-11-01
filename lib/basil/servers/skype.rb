#
# A legit skype bot!
#
# To use: create a profile to represent the bot, install and start skype
# on the same machine. Make sure nfelger's skype gem and the dbus
# connection it requires is up and running.
#
module Basil
  module Server
    class SkypeBot
      include Basil

      def run
        # https://github.com/nfelger/skype
        require 'skype'

        Skype.on(:chatmessage_received) do |chatmessage|
          from = from_name = body = nil

          # from/from_name requires my fork of the skype gem
          chatmessage.from      { |f|  from      = f  }
          chatmessage.from_name { |fn| from_name = fn }
          chatmessage.body      { |b|  body      = b  }

          chatmessage.chat do |chat|
            to, text = parse_body(body)
            msg = Message.new(to, from, from_name, text)

            begin
              reply = dispatch(msg)
              send_to_chat(chat, msg) if reply
            rescue Exception => e
              chat.send_message("error: #{e.message}")
            end
          end
        end

        Skype.attach

        listen_for_broadcasts do |msg|
          Skype.chats do |chats|
            chats.each do |chat|
              send_to_chat(chat, msg)
            end
          end
        end

        Thread.list.each{|t| t.join}
      end

      private

      def send_to_chat(chat, msg)
        prefix = "#{msg.to.split(' ').first}, " rescue ''
        chat.send_message(prefix + msg.text)
      end

      def parse_body(body)
        if body =~ /^!(.*)/
          to   = Config.me
          text = $1
        elsif body =~ /^>(.*)/
          to   = Config.me
          text = "eval#{$1}"
        elsif body =~ /^(\w+)[,;:] *(.*)$/
          to   = $1
          text = $2
        else
          to   = nil
          text = body
        end

        [to, text]
      end
    end
  end
end
