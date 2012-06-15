module Basil
  class Cli < Server
    def start
      loop do
        print '> '; str = $stdin.gets.chomp
        msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str, 'cli')

        puts reply.text if reply = dispatch_message(msg)
      end
    end
  end
end
