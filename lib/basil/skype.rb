require 'skype'

module Basil
  module SkypeProxy
    # Listens for a message in chat and yields the chat object and a
    # constructed Messsage to the block given.
    def self.on_message
      return unless block_given?

      # for some reason, using the nested block approach seems to make
      # things quicker and more consistent
      Skype.on(:chatmessage_received) do |chatmessage|
        chatmessage.chat do |chat|
          Skype::Api.invoke("GET CHAT #{chat.chatname} MEMBERS") do |resp|
            is_private = false #resp =~ /MEMBERS (.*)/ && $1.split(/ +/).length == 2

            chatmessage.from do |from|
              chatmessage.from_name do |from_name|
                chatmessage.body do |body|
                  to, text = parse_body(body)
                  to = Config.me if !to && is_private
                  yield chat, Message.new(to, from, from_name, text)
                end
              end
            end
          end
        end
      end

      Skype.attach
    end

    # Sends the message to that specific chat. Adds a prefix if there is
    # a defined to.
    def self.send_message(chat, msg)
      prefix = "#{msg.to.split(' ').first}, " rescue ''
      chat.send_message(prefix + msg.text)
    end

    # Calls block for each chat your in
    def self.each_chat
      Skype.chats do |chats|
        chats.each do |chat|
          yield chat
        end
      end
    end

    private

    def self.parse_body(body)
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
