require 'net/imap'

module Basil
  module Email
    # Looping in its own Thread, check the configured email address on
    # the given interval.
    #
    # Each mail found via IMAP will be turned into a  Email::Mail and
    # handed to the create_message method on each object in the
    # Plugin.email_strategies Array. Plugins can add objects to this
    # Arry via Basil.check_email.
    #
    # When an object returns a Message, both the Message and triggering
    # object will be yielded to the block which should handle the
    # server-specific task of sending the message to chat. This gives
    # the triggering object a chance to choose which chat the server
    # should send to.
    #
    # Notes:
    #
    # 1. If multiple strategy objects return Messages for the given
    #    Mail, they will all be yielded
    # 2. Messages are always deleted from the IMAP server after
    #    processing
    #
    def check_email(interval, &block)
      Thread.new do
        loop do
          with_imap do |imap|
            imap.search(['NOT', 'DELETED']).each do |message_id|
              mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])

              Plugin.email_strategies.each do |strategy|
                if strategy.respond_to?(:create_message)
                  begin
                    message = strategy.create_message(mail)
                    yield(strategy, message) if message
                  rescue Exception => ex
                    $stderr.puts "Error processing mail #{mail['Subject']}, #{ex}"
                  end
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
