require 'skype'
require 'skype/ext'

module Basil
  class Skype < Server
    def start
      info "starting skype server"

      super

      skype.on_chatmessage_received do |id|
        msg = build_message(id)

        if reply = dispatch_message(msg)
          info "sending #{reply.pretty}"
          prefix = reply.to ? "#{reply.to.split(' ').first}, " : ''
          skype.message_chat(msg.chat, prefix + reply.text)
        end
      end

      skype.connect
      skype.run
    end

    lock_start

    def broadcast_message(msg)
      info "broadcasting #{msg.pretty}"

      (skype.chats || []).each do |name|
        topic = skype.get("CHAT #{name} TOPIC").strip

        if [topic, name].include?(msg.chat)
          debug "topic or name match, sending broadcast"
          skype.message_chat(name, msg.text)
        end
      end
    end

    private

    def skype
      @skype ||= ::Skype.new(Config.me).tap do |skype|
        skype.debug = Logger.level == ::Logger::DEBUG
        skype.setup_chats_handler
      end
    end

    def build_message(message_id)
      chatname     = skype.get("CHATMESSAGE #{message_id} CHATNAME")
      from         = skype.get("CHATMESSAGE #{message_id} FROM_HANDLE")
      from_name    = skype.get("CHATMESSAGE #{message_id} FROM_DISPNAME")
      body         = skype.get("CHATMESSAGE #{message_id} BODY")
      private_chat = skype.get("CHAT #{chatname} MEMBERS").split(' ').length == 2

      to, text = parse_body(body)
      to = Config.me if !to && private_chat

      Message.new(to, from, from_name, text, chatname)
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
