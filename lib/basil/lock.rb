module Basil
  class Lock
    class << self
      def guard!
        if File.exists?(Config.lock_file)
          raise "Lock file present at #{Config.lock_file}! If you're " +
                "sure no other process is running, remove this file and " +
                "try again."
        end
      end

      def set
        File.open(Config.lock_file, 'w') do |fh|
          fh.write('')
        end
      end

      def unset
        if File.exists?(Config.lock_file)
          File.unlink(Config.lock_file)
        end
      end
    end
  end
end
