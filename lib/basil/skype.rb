require 'skype'
require 'skype/ext'

module Basil
  class Skype < Server

    lock_start

    def main_loop
      skype.on_chatmessage_received { |id| yield(id) }
      skype.connect
      skype.run
    end

    def accept_message(message_id)
      body         = skype.get("CHATMESSAGE #{message_id} BODY")
      chatname     = skype.get("CHATMESSAGE #{message_id} CHATNAME")
      private_chat = skype.get("CHAT #{chatname} MEMBERS").split(' ').length == 2

      to, text = parse_body(body)
      to = Config.me if !to && private_chat

      Message.new(
        :from      => skype.get("CHATMESSAGE #{message_id} FROM_HANDLE"),
        :from_name => skype.get("CHATMESSAGE #{message_id} FROM_DISPNAME"),
        :to        => to,
        :chat      => chatname,
        :text      => text
      )

    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
    end

    def send_message(msg)
      prefix = msg.to && "#{msg.to.split(' ').first}, "
      skype.message_chat(msg.chat, "#{prefix}#{msg.text}")
    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
    end

    private

    def skype
      @skype ||= ::Skype.new(Config.me)
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
