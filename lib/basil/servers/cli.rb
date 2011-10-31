#
# For light-weight development and plugin testing, a basic REPL prompt.
#
module Basil
  module Server
    class Cli
      include Basil

      def run
        while true
          print '> '; str = $stdin.gets.chomp
          msg = Message.new(Config.me, 'dave', 'Dave', str)
          begin
            reply = dispatch(msg)
            puts reply.text if reply
          rescue Exception => e
            puts "error: #{e.message}"
          end
        end
      end
    end
  end
end
