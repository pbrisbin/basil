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

          # basil only works with handles for to/from; from_name is
          # there but i haven't decided how/where to expose it for
          # plugins to use
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
