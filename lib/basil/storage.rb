module Basil
  # Basil's persistent storage is implmented through simple, unchecked
  # use of a PStore file. Plugins should take care not to step on other
  # plugins' data.
  #
  # The Config key pstore_file defines the location of the pstore file,
  # it defaults to /tmp/basil.pstore
  module Storage
    def self.with_storage
      require "pstore"
      result = nil

      @@pstore ||= ::PStore.new(pstore_file)
      @@pstore.transaction do
        result = yield @@pstore
      end

      result
    end

    private

    def self.pstore_file
      @@pstore_file ||= Config.pstore_file rescue '/tmp/basil.pstore'
    end
  end
end
