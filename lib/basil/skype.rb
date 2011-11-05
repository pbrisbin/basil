require 'skype'

module Basil
  module SkypeProxy
    # Listens for a message in chat and yields the chat object and a
    # constructed Messsage to the block given.
    def self.on_message
      return unless block_given?

      Skype.on(:chatmessage_received) do |chatmessage|
        from = from_name = body = nil

        chatmessage.from      { |f| from      = f }
        chatmessage.from_name { |n| from_name = n }
        chatmessage.body      { |b| body      = b }

        chatmessage.chat do |chat|
          to, text = parse_body(body)
          yield chat, Message.new(to, from, from_name, text)
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
