module Basil
  module Daemon
    class << self

      def start(foreground = Config.foreground?)
        if foreground
          Config.server.start
        else
          pid = fork_process
          puts "forked. pid: #{pid}"
        end
      end

      def stop
        pid = File.read(Config.pid_file).strip rescue nil
        pid && system("kill #{pid}")
      end

      private

      def fork_process
        fork do
          redirect_io

          logger.info "=== Started: #{Process.pid} ==="

          File.open(Config.pid_file, 'w') do |fh|
            fh.puts "#{Process.pid}"
          end

          Config.server.start
        end
      end

      def redirect_io
        quietly { STDIN.reopen('/dev/null') }

        ex = quietly do
          STDOUT.reopen(Config.log_file, 'a')
          STDOUT.sync = true
        end

        if ex && ex.is_a?(Exception)
          logger.warn ex
          logger.warn 'Closing stdout entirely'

          quietly { STDOUT.reopen('/dev/null') }
        end

        quietly do
          STDERR.reopen(STDOUT)
          STDERR.sync = true
        end
      end

      def quietly(&block)
        yield
      rescue Exception => ex
        ex
      end

      def logger
        @logger ||= Loggers['daemon']
      end

    end
  end
end
