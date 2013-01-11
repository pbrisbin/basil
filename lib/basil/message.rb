module Basil
  class Message
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

    def to_me?
      to && to.downcase == Config.me.downcase
    end

    def dispatch(server)
      ChatHistory.store_message(self)

      self.server = server

      dispatch_through(Plugin.responders) if to_me?
      dispatch_through(Plugin.watchers)
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

    def to_s
      "#<Message chat: #{chat.inspect}, to: #{to.inspect}, from: #{from}/#{from_name}, text: \"#{text}\" >"
    end

    private

    def dispatch_through(plugins)
      plugins.each do |p|
        if p.regex =~ text
          p.set_context(self, $~)
          p.execute
        end
      end
    end

  end
end
