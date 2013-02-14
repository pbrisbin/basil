require 'net/imap'

module Basil
  module Email
    class Checker
      def run
        with_imap do |imap|
          imap.search(['NOT', 'DELETED']).each do |message_id|
            logger.debug "Found message #{message_id}"
            handle_message_id(imap, message_id)
          end
        end
      rescue => ex
        logger.error ex
      end

      private

      def handle_message_id(imap, message_id)
        mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])
        mail and mail.dispatch
        logger.debug "Handled message #{message_id}"
      rescue => ex
        logger.error ex
      ensure
        delete_message_id(imap, message_id)
      end

      def delete_message_id(imap, message_id)
        imap.store(message_id, "+FLAGS", [:Deleted])
        logger.debug "Deleted message #{message_id}"
      rescue => ex
        logger.error ex
      end

      def with_imap(config = Config.email, &block)
        imap = connect_to_imap(config)

        yield imap

      ensure
        disconnect(imap) if imap
      end

      def connect_to_imap(config)
        logger.debug "Connecting to IMAP"
        imap = Net::IMAP.new(config['server'], config['port'], true)
        imap.login(config['username'], config['password'])
        imap.select(config['inbox'])

        imap
      end

      def disconnect(imap)
        imap.logout
        imap.disconnect
        logger.debug "Disconnected from IMAP"
      end

      def logger
        @logger ||= Loggers['email']
      end

    end
  end
end
