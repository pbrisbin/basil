module Basil
  module Server
    # A mock server used by the test suite.
    class Mock
      def run

      end

      def process(text, options = {})
        options = { :from      => 'test-user',
                    :from_name => 'Test User',
                    :to        => Config.me,
                    :chat      => 'test-session' }.merge(options)


        msg = Message.new(options[:to], options[:from], options[:from_name], text, options[:chat])

        ChatHistory.store_message(msg)

        if reply = Basil.dispatch(msg)
          return reply
        end

        nil
      end
    end
  end
end
