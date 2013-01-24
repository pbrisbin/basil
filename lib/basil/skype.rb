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
      logger.info "Accepting #{message_id}"

      msg = SkypeMessage.new(skype, message_id)

      Message.new(
        :from      => msg.from_handle,
        :from_name => msg.from_dispname,
        :to        => msg.to,
        :chat      => msg.chatname,
        :text      => msg.text
      )

    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
    end

    def send_message(msg)
      logger.info "Sending \"#{msg.text}\" to #{msg.chat}"

      prefix = msg.to && "#{msg.to.split(' ').first}, "
      skype.message_chat(msg.chat, "#{prefix}#{msg.text}")
    rescue ::Skype::Errors::GeneralError => ex
      logger.error ex; nil
    end

    private

    def skype
      @skype ||= ::Skype.new(Config.me)
    end

  end
end
