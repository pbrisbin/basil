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

      def run
        # https://github.com/nfelger/skype
        require 'skype'

        Skype.on(:chatmessage_received) do |chatmessage|
          from = from_name = body = nil

          # from/from_name requires my fork of the skype gem which is
          # not yet on github
          chatmessage.from      { |f|  from      = f  }
          chatmessage.from_name { |fn| from_name = fn }
          chatmessage.body      { |b|  body      = b  }

          chatmessage.chat do |chat|
            to, text = parse_body(body)
            msg = Message.new(to, from, from_name, text)

            begin
              reply  = dispatch(msg)

              if reply
                prefix = reply.to ? "#{reply.to}, " : ''
                chat.send_message(prefix + reply.text)
              end
            rescue Exception => e
              chat.send_message("error: #{e.message}")
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
        elsif body =~ />(.*)/
          to   = Config.me
          text = "eval#{$1}"
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
