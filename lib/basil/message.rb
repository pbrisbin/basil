module Basil
  class Message
    # Who a Message is from and what it is are immutable
    attr_reader :from, :from_name, :text

    # Messages can be forwarded around by changing the to or chat
    # attributes
    attr_accessor :to, :chat

    def self.from_message(message, options = {})
      args = {
        :to        => message.to,
        :from      => message.from,
        :from_name => message.from_name,
        :text      => message.text,
        :chat      => message.chat
      }.merge(options)

      new(args)
    end

    def initialize(options)
      # required
      @from      = options.fetch(:from)      { raise ArgumentError, 'from is required' }
      @from_name = options.fetch(:from_name) { raise ArgumentError, 'from_name is required' }

      # optional
      @to   = options[:to]
      @chat = options[:chat]
      @text = options.fetch(:text, '')
    end

    def to_me?
      to.downcase == Config.me.downcase
    rescue
      false
    end

    def inspect
      "#<Message:#{object_id} chat: #{chat.inspect}, to: #{to.inspect}, from: #{from}/#{from_name}, text: #{text}>"
    end

  end
end
