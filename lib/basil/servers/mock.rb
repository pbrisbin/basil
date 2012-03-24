module Basil
  module Server
    # A mock server used by the test suite.
    class Mock
      def run

      end

      def process(text, to = Config.me)
        msg = Message.new(to, 'test-user', 'Test User', text, 'test')

        ChatHistory.store_message(msg)

        if reply = Basil.dispatch(msg)
          return reply
        end

        nil
      end
    end
  end
end
