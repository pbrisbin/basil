module Basil
  # The main basil data type: the Message. Servers should construct
  # these and pass them through dispatch which will also return a
  # Message if a response is triggered.
  class Message
    include Basil

    attr_reader :to, :from, :from_name, :time, :text, :chat

    def initialize(to, from, from_name, text, chat = nil)
      @time = Time.now
      @to, @from, @from_name, @text, @chat = to, from, from_name, text, chat
    end

    # Is this message to my configured nick?
    def to_me?
      to.downcase == Config.me.downcase
    rescue
      false
    end
  end
end
