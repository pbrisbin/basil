module Basil
  # Service module which allows for accessing up to +LIM+ previous
  # messages in any given chat. Servers must call store_message
  # pre-dispatch for every message they see.
  module ChatHistory
    KEY = :chat_history
    LIM = 100 # number of message to kep per chat

    class << self
      def store_message(message)
        with_history(message.chat) do |history|
          history.unshift(message)
          history.pop while history.length > LIM
        end
      end

      # Messages are returned most recent first. Valid option keys are
      # :from and :to which limit the results accordingly.
      def get_messages(chat, options = {})
        with_history(chat) do |history|
          messages = history.dup

          if options.has_key?(:from)
            messages.keep_if { |msg| msg.from_name =~ /#{options[:from]}/i }
          end

          if options.has_key?(:to)
            messages.keep_if { |msg| msg.to =~ /#{options[:to]}/i }
          end

          messages
        end
      end

      def clear_history(chat)
        with_history(chat, &:clear)
      end

      private

      def with_history(chat, &block)
        Storage.with_storage do |store|
          store[KEY]       ||= {}
          store[KEY][chat] ||= []

          yield(store[KEY][chat])
        end
      end
    end
  end
end
