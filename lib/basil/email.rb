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
      end
    end

    class << self
      # Check for email on the configured interval, if a mail is found
      # it is run through each of the email strategy plugins. Any
      # replies returned will be handed to the delegate's broadcast_mail
      # method.
      def check(delegate)
        # if the delegate doesn't support us, we just do nothing.
        return unless delegate.respond_to?(:broadcast_mail)

        @delegate = delegate

        Thread.new do
          loop do
            begin
              with_imap do |imap|
                imap.search(['NOT', 'DELETED']).each do |message_id|
                  handle_message_id(imap, message_id)
                end
              end

            rescue Exception => ex
              $stderr.puts "Error checking email: #{ex}"
            end

            sleep (Config.email['interval'] || 30)
          end
        end
      end

      private

      def handle_message_id(imap, message_id)
        mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])

        Plugin.email_strategies.each do |strategy|
          if msg = strategy.create_message(mail)
            @delegate.broadcast_message(msg)
          end
        end

      rescue Exception => ex
        $stderr.puts "Error handling message id #{message_id}: #{ex}"
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
        $stderr.puts "Error connecting to IMAP: #{ex}"
      ensure
        if imap
          imap.logout()
          imap.disconnect()
        end
      end
    end
  end
end
