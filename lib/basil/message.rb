module Basil
  class Message
    # Who a Message is from and what it is are immutable
    attr_reader :from, :from_name, :text, :time

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
      @from = options.fetch(:from) { raise ArgumentError, 'from is required' }

      @to        = options[:to]
      @from_name = options.fetch(:from_name, @from)
      @chat      = options[:chat]
      @text      = options.fetch(:text, '')
      @time      = Time.now
    end

    def to_me?
      to && to.downcase == Config.me.downcase
    end

    def dispatch
      if to_me? && (reply = dispatch_through(Plugin.responders))
        return reply
      end

      dispatch_through(Plugin.watchers)
    end

    def to_s
      "#<Message chat: #{chat.inspect}, to: #{to.inspect}, from: #{from}/#{from_name}, text: \"#{text}\" >"
    end

    private

    def dispatch_through(plugins)
      reply = nil

      plugins.each do |p|
        if p.regex =~ text
          p.set_context(self, $~)
          reply = p.execute and break
        end
      end

      reply
    end

  end
end
