require 'rype'

module Basil
  class Skype < Server
    def start
      # for some reason, using the nested block approach seems to make
      # things quicker and more consistent
      Rype.on(:chatmessage_received) do |chatmessage|
        chatmessage.chat do |chat|
          chat.members do |members|
            is_private = members.length == 2

            chatmessage.from do |from|
              chatmessage.from_name do |from_name|
                chatmessage.body do |body|
                  to, text = parse_body(body)

                  to  = Config.me if !to && is_private
                  msg = Message.new(to, from, from_name, text, chat.chatname)

                  if reply = delegate.dispatch_message(msg)
                    delegate.sending_message(reply)
                    send_message(chat, reply)
                  end
                end
              end
            end
          end
        end
      end

      Rype.attach
    end
    
    def broadcast_message(msg)
      Rype.chats do |chats|
        chats.each do |chat|
          chat.topic do |topic|
            if [topic, chat.chatname].include?(msg.chat)
              delegate.sending_message(msg)
              send_message(chat, msg)
            end
          end
        end
      end
    end

    private

    def send_message(chat, msg)
      prefix = msg.to ? "#{msg.to.split(' ').first}, " : ''
      chat.send_message(prefix + msg.text)
    end

    def parse_body(body)
      case body
      when /^! *(.*)/           ; [Config.me, $1]
      when /^> *(.*)/           ; [Config.me, "eval #{$1}"]
      when /^@(\w+)[,;:]? +(.*)/; [$1, $2]
      when /^(\w+)[,;:] +(.*)/  ; [$1, $2]
      else [nil, body]
      end
    end
  end
end
