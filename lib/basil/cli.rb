module Basil
  class Cli < Server
    def main_loop
      loop { print '> '; yield }
    end

    def accept_message(*args)
      Message.new(
        :to   => Config.me,
        :from => ENV['USER'],
        :text => $stdin.gets.chomp,
        :chat => 'cli'
      )
    end

    def send_message(msg)
      puts msg.text
    end
  end
end
