module Basil
  class Cli < Server
    def main_loop
      loop do
        print '> '
        r = yield and puts r.text
      end
    end

    def build_message(*args)
      Message.new(
        :to   => Config.me,
        :from => ENV['USER'],
        :text => $stdin.gets.chomp,
        :chat => 'cli'
      )
    end
  end
end
