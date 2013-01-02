require 'skype'
require 'skype/ext'

module Basil
  class Skype < Server
    def start
      info "starting skype server"

      super

      ::Skype.DEBUG = debug?

      @skype = ::Skype.new(Config.me)

      skype.command_manager = ::Skype::Delegator.new(skype, self)
      skype.connect
      skype.run
    end

    lock_start

    # Called on the CHATS api event
    def chats(args)
      @chatnames = args.split(', ')
    end

    # Called on the CHATMESSAGE api event
    def chatmessage(args)
      id, _, action = args.split(' ')

      if action.downcase == 'received'
        msg = build_message(id)

        if reply = dispatch_message(msg)
          info "sending #{reply.pretty}"
          prefix = reply.to ? "#{reply.to.split(' ').first}, " : ''
          skype.message_chat(msg.chat, prefix + reply.text)
        end
      end
    end

    def broadcast_message(msg)
      info "broadcasting #{msg.pretty}"

      Timeout.timeout(3) do
        @chatnames = nil
        skype.send_raw_command('SEARCH CHATS')
        sleep 0.1 while @chatnames.nil?
      end

      @chatnames.each do |name|
        topic = skype.get("CHAT #{name} TOPIC").strip

        if [topic, name].include?(msg.chat)
          debug "topic or name match, sending broadcast"
          skype.message_chat(name, msg.text)
        end
      end
    end

    private

    attr_reader :skype

    def debug?
      Logger.level == ::Logger::DEBUG
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
