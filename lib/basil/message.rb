module Basil
  class Message
    include Dispatchable

    attr_reader :from, :from_name, :text, :time
    attr_accessor :to, :chat, :server

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

    def each_plugin(&block)
      Plugin.responders.each(&block) if to_me?
      Plugin.watchers.each(&block)
    end

    def match?(plugin)
      plugin.regex.match(text)
    end

    def to_me?
      to && to.downcase == Config.me.downcase
    end

    def say(text)
      server && server.send_message(
        Message.from_message(self, :to => nil, :text => text)
      )
    end

    def reply(text)
      server && server.send_message(
        Message.from_message(self, :to => self.from_name, :text => text)
      )
    end

    def forward(to)
      server && server.send_message(
        Message.from_message(self, :to => to)
      )
    end

    def to_message
      self
    end

    def to_s
      "#<Message chat: #{chat.inspect}, to: #{to.inspect}, from: #{from}/#{from_name}, text: \"#{text}\" >"
    end

  end
end
