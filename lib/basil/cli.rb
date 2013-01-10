module Basil
  class Cli < Server
    def main_loop
      loop do
        print '> '
        msg = Message.new(:to   => Config.me,
                          :from => ENV['USER'],
                          :text => $stdin.gets.chomp,
                          :chat => 'cli')

        if reply = dispatch_message(msg)
          puts reply.text
        end
      end
    end
  end
end
