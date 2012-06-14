module Basil
  class Cli < Server
    def start
      loop do
        print '> '; str = $stdin.gets.chomp
        msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str, 'cli')

        if reply = dispatch_message(msg)
          sending_message(reply)
          puts reply.text
        end
      end
    end
  end
end
