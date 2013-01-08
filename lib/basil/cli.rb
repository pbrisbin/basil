module Basil
  class Cli < Server
    has_command(:quit) do |*args|
      exit 0
    end

    def start
      super

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
