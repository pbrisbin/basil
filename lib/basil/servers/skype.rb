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
        require 'skype'

        Skype.on(:chatmessage_received) do |chatmessage|
          from = from_name = body = nil

          chatmessage.from      { |f|  from      = f  }
          chatmessage.from_name { |fn| from_name = fn }
          chatmessage.body      { |b|  body      = b  }

          chatmessage.chat do |chat|
            to, text = parse_body(body)
            msg = Message.new(to, from, from_name, text)
            puts "<<- " + msg.inspect

            begin
              if reply = dispatch(msg)
                puts "->> " + reply.inspect
                send_to_chat(chat, reply)
              end
            rescue Exception => e
              chat.send_message("error: #{e.message}")
            end
          end
        end

        Skype.attach

        Broadcast.on(:broadcast_recieved) do |msg|
          Skype.chats do |chats|
            chats.each do |chat|
              puts "-*->>" + msg.inspect
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
        return case body
               when /^!(.*)/            ; [Config.me, $1]
               when /^>(.*)/            ; [Config.me, "eval#{$1}"]
               when /^@(\w+)[,;:]? (.*)/; [$1, $2]
               when /^(\w+)[,;:] *(.*)/ ; [$1, $2]
               else [nil, body]
               end

      rescue Exception
        [nil, body]
      end
    end
  end
end
