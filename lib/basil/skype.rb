require 'rype'

module Basil
  module Skype
    # Listens for a message in chat and yields the chat object and a
    # constructed Messsage to the block given.
    def on_message
      return unless block_given?

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
                  msg = Message.new(to, from, from_name, text)
                  puts '<<- ' + msg.inspect

                  yield chat, msg
                end
              end
            end
          end
        end
      end

      Rype.attach
    end

    # Sends the message to that specific chat. Adds a prefix if there is
    # a defined to.
    def send_message(chat, msg)
      puts '->> ' + msg.inspect
      prefix = "#{msg.to.split(' ').first}, " rescue ''
      chat.send_message(prefix + msg.text)
    end

    # Calls block for each chat your in
    def each_chat
      Rype.chats do |chats|
        chats.each do |chat|
          yield chat
        end
      end
    end

    private

    def parse_body(body)
      return case body
             when /^! *(.*)/           ; [Config.me, $1]
             when /^> *(.*)/           ; [Config.me, "eval #{$1}"]
             when /^@(\w+)[,;:]? +(.*)/; [$1, $2]
             when /^(\w+)[,;:] +(.*)/  ; [$1, $2]
             else [nil, body]
             end

    rescue
      [nil, body]
    end
  end
end
