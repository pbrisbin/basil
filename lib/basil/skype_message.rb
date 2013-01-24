module Basil
  class SkypeMessage
    BODY_MASK = /^(?:@(\w+)[,;:]?\s+|(\w+)[,;:]\s+)?(.*)/

    attr_reader :chatname,
                :from_handle,
                :from_dispname,
                :body, :private_chat

    alias :private_chat? :private_chat

    def initialize(skype, message_id)
      @chatname      = skype.get("CHATMESSAGE #{message_id} CHATNAME")
      @from_handle   = skype.get("CHATMESSAGE #{message_id} FROM_HANDLE")
      @from_dispname = skype.get("CHATMESSAGE #{message_id} FROM_DISPNAME")
      @body          = skype.get("CHATMESSAGE #{message_id} BODY")
      @private_chat  = skype.get("CHAT #{chatname} MEMBERS").split(' ').length == 2
    end

    def to
      captures[0] || captures[1]
    end

    def text
      captures.last
    end

    private

    def captures
      @captures ||= BODY_MASK.match(adjusted_body).captures
    end

    def adjusted_body
      if body =~ /^(!|>)/
        return body.sub(/^!\s*/, "#{Config.me}, ")
                   .sub(/^>\s*/, "#{Config.me}, eval ")
      end

      private_chat? ? "#{Config.me}, #{body}" : body
    end

  end
end
