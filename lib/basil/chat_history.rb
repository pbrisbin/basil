module Basil
  module ChatHistory
    KEY = :chat_history
    LIM = 100 # number of message to kep per chat

    # All servers should call this with messages as they receive them so
    # they can be added to the chat history.
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
            msg.from_name =~ /#{options[:from]}/i rescue false
          end
        end

        if options.has_key?(:to)
          # messages to someone
          history = history.select do |msg|
            msg.to =~ /#{options[:to]}/i rescue false
          end
        end
      end

      history || []

    rescue Exception => ex
      $stderr.puts "Exception getting chat history. options: #{options.inspect}; exception: #{ex}."
      return []
    end

    def purge_history!(chat = @msg.chat)
      Storage.with_storage do |store|
        store[KEY].delete(chat)
      end
    rescue
    end
  end
end
