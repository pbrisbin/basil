module Basil
  module Server
    # A simple commandline interface. Assumes all messages are to basil
    # from environment variable USER.
    class Cli
      include Basil

      def run
        loop do
          print '> '; str = $stdin.gets.chomp
          msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str)

          begin
            if reply = Basil.dispatch(msg)
              puts reply.text
            end
          rescue Exception => ex
            $stderr.puts "error: #{ex}"
          end

        end
      end
    end
  end
end
