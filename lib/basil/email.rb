require 'net/imap'

module Basil
  module Email
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
          do_check(&block)

          sleep interval
        end
      end
    end

    private

    def do_check(&block)
      with_imap do |imap|
        imap.search(['NOT', 'DELETED']).each do |message_id|
          handle_message_id(message_id, &block)
        end
      end

    rescue Exception => ex
      $stderr.puts "Error checking email: #{ex}"
    end

    def handle_message_id(message_id, &block)
      mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])

      Plugin.email_strategies.each do |strategy|
        if strategy.respond_to?(:create_message)
          message = strategy.create_message(mail)
          yield(strategy, message) if message
        end
      end

    rescue Exception => ex
      $stderr.log "Error handling message id #{message_id}: #{ex}"
    ensure
      # we always, always delete the message. this stops malformed mails
      # from causing recurring problems and prevents any duplicate
      # processing. only risk is a dropped email here or there.
      imap.store(message_id, "+FLAGS", [:Deleted])
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
  end
end
