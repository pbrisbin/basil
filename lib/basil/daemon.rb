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
          Loggers.output = Config.log_file

          logger.info "=== Started: #{Process.pid} ==="

          File.open(Config.pid_file, 'w') do |fh|
            fh.puts "#{Process.pid}"
          end

          close_io

          Config.server.start
        end
      end

      def close_io
        [STDIN, STDOUT].each do |io|
          begin io.reopen("/dev/null")
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
