module Basil
  # Service module which allows for accessing up to +LIM+ previous
  # messages in any given chat. Servers must call store_message
  # pre-dispatch for every message they see.
  module ChatHistory
    KEY = :chat_history
    LIM = 100 # number of message to kep per chat

    def self.store_message(message)
      Storage.with_storage do |store|
        store[KEY]               ||= {}
        store[KEY][message.chat] ||= []
        store[KEY][message.chat].unshift(message)

        while store[KEY][message.chat].length > LIM
          store[KEY][message.chat].pop
        end
      end
    end

    # Messages are returned most recent first. Valid option keys are
    # :from and :to which limit the results accordingly.
    def self.get_messages(chat, options = {})
      Storage.with_storage do |store|
        history = store[KEY][chat] || []

        if options.has_key?(:from)
          # messages from someone
          history = history.select do |msg|
            msg.from_name =~ /#{options[:from]}/i
          end
        end

        if options.has_key?(:to)
          # messages to someone
          history = history.select do |msg|
            msg.to =~ /#{options[:to]}/i
          end
        end

        history
      end
    end

    def self.clear_history(chat)
      Storage.with_storage do |store|
        store[KEY].delete(chat)
      end
    end
  end
end
