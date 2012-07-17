require 'rype'

module Basil
  class Skype < Server
    def start
      debug "starting skype server"

      Rype::Logger.set(Basil::Logger)

      # Note: there are a number of oddities in how the dbus connection
      # behaves. Also, if you break this code by violating the below,
      # you won't get an exception, basil just stops listening.
      #
      # Therefore, if you touch this method, keep in mind the following:
      #
      # 1. You must use nested blocks when you need to access multiple
      #    parts of a skype object.
      #
      # 2. The order of your nesting seems to matter. Though I've yet to
      #    determine how or why.
      #
      # 3. Sometimes, it's required you use the block argument
      #    immediately.
      #
      Rype.on(:chatmessage_received) do |chatmessage|
        chatmessage.from do |from|
          chatmessage.from_name do |from_name|
            chatmessage.body do |body|
              chatmessage.chat do |chat|
                chat.members do |members|
                  is_private = members.length == 2
                  to, text   = parse_body(body)

                  debug "chat name: #{chat.chatname}"
                  debug "private chat: #{is_private}"

                  to  = Config.me if !to && is_private
                  msg = Message.new(to, from, from_name, text, chat.chatname)

                  if reply = dispatch_message(msg)
                    debug "sending #{reply.pretty}"
                    prefix = reply.to ? "#{reply.to.split(' ').first}, " : ''
                    chat.send_message(prefix + reply.text)
                  end
                end
              end
            end
          end
        end
      end

      Rype.attach
      Rype.thread.join
    end

    lock_start
    
    def broadcast_message(msg)
      debug "broadcasting #{msg.pretty}"

      Rype.chats do |chats|
        chats.each do |chat|
          chat.topic do |topic|
            if [topic, chat.chatname].include?(msg.chat)
              debug "topic or name match, sending broadcast"
              chat.send_message(msg.text)
            end
          end
        end
      end
    end

    private

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
