module Basil
  class Lock
    class << self
      def guard(&block)
        error if File.exists?(Config.lock_file)

        begin
          File.open(Config.lock_file, 'w') { }

          yield

        ensure
          File.unlink(Config.lock_file)
        end
      end

      def error
        raise "Lock file present at #{Config.lock_file}! If you're " +
              "sure no other process is running, remove this file and " +
              "try again."
      end
    end
  end
end
