require 'net/imap'
require 'basil/email/mail'

module Basil
  module Email
    class << self
      # Check for email on the configured interval, if a mail is found
      # it is run through each of the email checker plugins. Any replies
      # returned will be handed to the server's broadcast_mail method.
      def check
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
        if mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])
          logger.info "Dispatching #{mail}"

          if reply = Dispatch.simple(mail)
            logger.info "Broadcasting: #{reply}"
            Config.server.broadcast_message(reply)
          end
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
