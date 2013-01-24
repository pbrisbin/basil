module Basil
  class SkypeMessage
    # We can assume this always matches since the first group is
    # optional and the second group is effectively +.*+
    BODY_MASK =
      /
        ^( @(?<to>\w+)[,;:]?\s+ | # @name style
            (?<to>\w+)[,;:]\s+    # using punctuation
         )?
         (?<text>.*)$             # rest of message
      /x

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
      matched_body[:to]
    end

    def text
      matched_body[:text]
    end

    private

    def matched_body
      @matched_body ||= BODY_MASK.match(adjusted_body)
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
