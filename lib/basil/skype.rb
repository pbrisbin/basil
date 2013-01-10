require 'skype'
require 'skype/ext'

module Basil
  class Skype < Server
    def main_loop
      skype.on_chatmessage_received do |id|
        msg = get_message(id)

        if reply = dispatch_message(msg)
          prefix = reply.to ? "#{reply.to.split(' ').first}, " : ''
          message_chat(msg.chat, prefix + reply.text)
        end
      end

      skype.connect
      skype.run
    end

    lock_start

    def broadcast_message(msg)
      message_chat(msg.chat, msg.text)
    end

    private

    def skype
      @skype ||= ::Skype.new(Config.me)
    end

    def message_chat(chat, text)
      skype.message_chat(msg.chat, msg.text)
    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
    end

    def get_message(message_id)
      body         = skype.get("CHATMESSAGE #{message_id} BODY")
      chatname     = skype.get("CHATMESSAGE #{message_id} CHATNAME")
      private_chat = skype.get("CHAT #{chatname} MEMBERS").split(' ').length == 2

      to, text = parse_body(body)
      to = Config.me if !to && private_chat

      Message.new(:from      => skype.get("CHATMESSAGE #{message_id} FROM_HANDLE"),
                  :from_name => skype.get("CHATMESSAGE #{message_id} FROM_DISPNAME"),
                  :to        => to,
                  :chat      => chatname,
                  :text      => text)

    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
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
