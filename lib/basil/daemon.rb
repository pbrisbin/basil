module Basil
  module Daemon
    class << self
      def start(foreground = Config.foreground?)
        if foreground
          Config.server.start
        else
          start_in_background
        end
      end

      def stop
        if pid = read_pid
          system("kill #{pid}")
        end
      end

      private

      def start_in_background
        pid = fork do
          Loggers.output = Config.log_file

          logger.info "=== Started: #{Process.pid} ==="

          write_pid
          close_io

          Config.server.start
        end

        puts "forked. pid: #{pid}"
      end

      def write_pid
        File.open(Config.pid_file, 'w') do |fh|
          fh.puts "#{Process.pid}"
        end
      end

      def read_pid
        File.read(Config.pid_file).strip
      rescue => ex
        logger.debug ex; nil
      end

      def close_io
        [STDIN, STDOUT].each do |io|
          begin
            io.reopen("/dev/null")
          rescue Exception
          end
        end

        STDERR.reopen(STDOUT)
        STDERR.sync = true
      rescue Exception
      end

      def logger
        @logger ||= Loggers['daemon']
      end

    end
  end
end
