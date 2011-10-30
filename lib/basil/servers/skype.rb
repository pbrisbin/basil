#
# A legit skype bot!
#
# To use: create a profile to represent the bot, install and start skype
# on the same machine. Make sure nfelger's skype gem and the dbus
# connection it requires is up and running.
#
module Basil
  module Server
    class SkypeBot
      include Basil

      def initialize
        # https://github.com/nfelger/skype
        require 'skype'
      end

      def run
        Skype.on(:chatmessage_received) do |chatmessage|
          chatmessage.chat do |chat|
            chatmessage.body do |body|
              to, text = parse_body(body)
              msg = Message.new(to, nil, text)

              begin
                reply = dispatch(msg)
                chat.send_message(reply.text) if reply
              rescue Exception => e
                chat.send_message(e.message)
              end
            end
          end
        end

        Skype.attach

        Thread.list.each{|t| t.join}
      end

      private

      def parse_body(body)
        if body =~ /!(.*)/
          to   = Config.me
          text = $1
        elsif body =~ /^(\w+)[,;:] *(.*)$/
          to   = $1
          text = $2
        else
          to   = nil
          text = body
        end

        [to, text]
      end
    end
  end
end
