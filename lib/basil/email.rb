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

      def to_s
        "#<Mail from: #{self['From']}, subject: #{self['Subject']} >"
      end

      def self.parse(content)
        header_lines = []
        headers      = {}

        lines = content.split(/\r\n/)

        while !(line = lines.shift).empty?
          if line =~ /^\s+(.*)/ # continuation
            last = header_lines.pop
            line = "#{last} #{$1}" if last
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
      # it is run through each of the email checker plugins. Any replies
      # returned will be handed to the server's broadcast_mail method.
      def check
        # if the server doesn't support us, we just do nothing.
        if Config.server.respond_to?(:broadcast_message)
          logger.debug "Server supports broadcasting"
        else
          logger.debug "Server does not support broadcasting"; return
        end

        Thread.new do
          logger.debug "Email polling spawned"

          loop do
            poll_email

            break unless poll_email?

            sleep(Config.email['interval'] || 30)
          end
        end
      end

      private

      def poll_email
        with_imap do |imap|
          imap.search(['NOT', 'DELETED']).each do |message_id|
            handle_message_id(imap, message_id)
          end
        end

      rescue Exception => ex
        logger.error ex
      end

      def handle_message_id(imap, message_id)
        mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])

        if reply = Dispatch.email(mail)
          logger.info "Broadcasting: #{reply}"
          Config.server.broadcast_message(reply)
        end

      rescue Exception => ex
        logger.warn ex
      ensure
        # we always, always delete the message. this stops malformed mails
        # from causing recurring problems and prevents any duplicate
        # processing. only risk is a dropped email here or there.
        imap.store(message_id, "+FLAGS", [:Deleted]) rescue $!
      end

      def with_imap(config = Config.email, &block)
        logger.debug 'Logging into IMAP'
        imap = Net::IMAP.new(config['server'], config['port'], true)
        imap.login(config['username'], config['password'])
        imap.select(config['inbox'])

        yield imap

      ensure
        if imap
          imap.logout()
          imap.disconnect()
          logger.debug 'Disconnected from IMAP'
        end
      end

      def poll_email?
        # right now we just use this to prevent looping during testing,
        # eventually this might be used to allow an in-chat command to
        # shut down the polling (or something)
        true
      end

      def logger
        @logger ||= Loggers['email']
      end
    end
  end
end
