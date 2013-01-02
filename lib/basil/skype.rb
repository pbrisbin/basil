require 'skype'

class Skype
  attr_writer :command_manager

  def get(property)
    response = send_raw_command("GET #{property}")
    response[property.length..-1].strip
  end

  def message_chat(name, message)
    send_raw_command("CHATMESSAGE #{name} #{message}")
  end
end

module Basil
  class Skype < Server
    attr_reader :skype
    attr_writer :chatnames

    def start
      info "starting skype server"

      super

      ::Skype.DEBUG = debug?

      @skype = ::Skype.new(Config.me)

      skype.command_manager = CommandManager.new(self)
      skype.connect
      skype.run
    end

    lock_start

    def handle_message(message_id)
      msg = build_message(message_id)

      if reply = dispatch_message(msg)
        info "sending #{reply.pretty}"
        prefix = reply.to ? "#{reply.to.split(' ').first}, " : ''
        skype.message_chat(msg.chat, prefix + reply.text)
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

  # This class quacks like a ::Skype::CommandManager but is constructed
  # with a reference to the running server and delegates to it. Also
  # fixes a bug in #process_command that prevented commands that return
  # empty responses from being usable.
  class CommandManager < ::Skype::CommandManager
    def initialize(server)
      @skype  = server.skype
      @server = server
    end

    def process_command(command)
      command, args = command.split(/\s+/, 2)
      command = command.downcase.to_sym rescue nil

      if command && self.public_methods.include?(command)
        self.send(command, args)
      end
    end

    def chats(args)
      @server.chatnames = args.split(', ')
    end

    def chatmessage(args)
      id, _, action = args.split(' ')

      if action.downcase == 'received'
        @server.handle_message(id)
      end
    end
  end
end
