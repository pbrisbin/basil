module Basil
  module Server
    # A simple commandline interface. Assumes all messages are to basil
    # from environment variable USER.
    class Cli
      include Basil

      def run
        loop do
          print '> '; str = $stdin.gets.chomp
          msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str, 'cli')

          ChatHistory.store_message(msg)

          begin
            if reply = dispatch(msg)
              puts reply.text
            end
          rescue Exception => ex
            $stderr.puts "error: #{ex}"
          end

        end
      end

      def dispatch(msg)
        if (Config.extended_readline rescue false)
          Readline.dispatch(msg)
        else
          Basil.dispatch(msg)
        end
      end
    end
  end
end
