require "pstore"

module Basil
  # Basil's persistent storage is implemented through simple, unchecked
  # use of a PStore file. Plugins should take care not to step on other
  # plugins' data.
  module Storage
    class << self
      def with_storage(&block)
        result = nil

        pstore.transaction do
          result = yield pstore
        end

        result
      end

      private

      def pstore
        @pstore ||= PStore.new(Config.pstore_file)
      end
    end
  end
end
