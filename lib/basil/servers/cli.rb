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
          msg = Message.new(Config.me, 'user', str)
          reply = dispatch(msg)
          puts reply.text if reply
        end
      end
    end
  end
end
