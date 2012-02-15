require 'net/imap'

module Basil
  # Note: to prevent "catch-up" spam the first time this is enabled or
  # renabled after breaking (say it ain't so!), I recommend clearing
  # the bot's inbox (manually or by running a CLI instance).
  module Email
    # Looping in its own Thread, check the configured email address on
    # the given interval.
    #
    # You should pass in one or an Array of objects which respond to
    # create_message accepting a Basil::Email::Mail and returning a
    # Basil::Message (or nil).
    #
    # When an object returns a Message, the strategy object and the
    # message are yielded to the block which should handle the
    # server-specific task of sending the message to chat.
    #
    # Note: if multiple strategy objects return Messages for the given
    # Mail, they will all be yielded.
    #
    # Messages are always deleted from the IMAP server after processing,
    # this is to aggressively prevent duplicate processing.
    def check_email(interval, strategies, &block)
      strategies = [strategies] unless strategies.is_a?(Array)

      Thread.new do
        loop do
          with_imap do |imap|
            imap.search(['NOT', 'DELETED']).each do |message_id|
              mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])

              strategies.each do |strategy|
                if strategy.respond_to?(:create_message)
                  message = strategy.create_message(mail)
                  yield(strategy, message) if message
                end
              end

              imap.store(message_id, "+FLAGS", [:Deleted])
            end
          end

          sleep interval
        end
      end
    rescue Exception => ex
      $stderr.puts "#{ex}"
    end

    def with_imap(config = Config.email, &block)
      imap = Net::IMAP.new(config['server'], config['port'], true)
      imap.login(config['username'], config['password'])
      imap.select(config['inbox'])

      yield imap

    rescue Exception => ex
      $stderr.puts "#{ex}"
    ensure
      if imap
        imap.logout()
        imap.disconnect()
      end
    end
    private :with_imap

    # This class represents a parsed email. Headers are accessed like
    # array indices and body is provided as a method. The parsing is
    # naive, but it works for our purpose.
    class Mail
      attr_reader :body

      def initialize(headers, body)
        @headers, @body = headers, body
      end

      def [](arg)
        @headers[arg]
      end

      def self.parse(content)
        header_lines = []
        headers      = {}
        body         = ""

        lines = content.split(/\r\n/)

        while !(line = lines.shift).empty?
          if line =~ /^\s+(.*)/ # continuation
            last = header_lines.pop
            line = last + $1 if last
          end

          header_lines << line
        end

        body = lines.join("\n")

        header_lines.each do |hl|
          if hl =~ /^([^:]+):(.*)$/
            headers[$1] = $2.strip
          end
        end

        new(headers, body)
      rescue Exception => ex
        $stderr.puts "#{ex}"
        new(headers, body)
      end
    end
  end
end
