module Basil
  class Cli < Server
    def start
      loop do
        print '> '; str = $stdin.gets.chomp
        msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str, 'cli')

        if reply = delegate.dispatch_message(msg)
          delegate.sending_message(msg)
          puts reply.text
        end
      end
    end
  end
end
