require "pstore"

module Basil
  module Storage
    class << self

      def with_storage(&block)
        pstore.transaction do
          yield pstore
        end
      end

      private

      def pstore
        @pstore ||= PStore.new(Config.pstore_file)
      end

    end
  end
end
