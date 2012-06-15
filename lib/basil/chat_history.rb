module Basil
  # The ChatHistory module allows for accessing up to +LIM+ previous
  # messages in the current chat. It should be mixed into Plugin as it
  # relies on an +@msg+ instance variable.
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

    # Get an array of messages representing this chat's history.
    # Messages are returned most recent first. Valid option keys are
    # :chat, :from and :to which limit the results accordingly.
    def chat_history(options = {})
      debug "accessing chat history with #{options}"

      history = []

      Storage.with_storage do |store|
        if options.has_key?(:chat)
          # history for some other chat
          history = store[KEY][options[:chat]]
        else
          # history for this chat
          history = store[KEY][@msg.chat]
        end

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
      end

      history || []
    end

    def purge_history!(chat = @msg.chat)
      debug "purging chat history for #{chat}"

      Storage.with_storage do |store|
        store[KEY].delete(chat)
      end
    end
  end
end
