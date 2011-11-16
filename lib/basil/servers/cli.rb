module Basil
  module Server
    # A simple commandline interface. Assumes all messages are to basil
    # from environment variable USER.
    class Cli
      include Basil

      def run
        Thread.new do
          loop do
            print '> '; str = $stdin.gets.chomp
            msg = Message.new(Config.me, ENV['USER'], ENV['USER'], str)
            begin
              reply = Basil.dispatch(msg)
              puts reply.text if reply
            rescue Exception => e
              puts "error: #{e.message}"
            end
          end
        end

        # on broadcast, print and reset the prompt
        Broadcast.on(:broadcast_recieved) { |msg| print "\n#{msg.text}\n> " }

        Thread.list.each{|t| t.join}
      end
    end
  end
end
