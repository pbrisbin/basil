require "pstore"

module Basil
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
