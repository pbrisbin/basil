module Basil
  module Email
    class Worker
      def run
        with_imap do |imap|
          imap.search(['NOT', 'DELETED']).each do |message_id|
            handle_message_id(imap, message_id)
          end
        end
      rescue => ex
        logger.warn ex
      end

      private

      def handle_message_id(imap, message_id)
        logger.debug "Handling message with ID #{message_id}"
        mail = Mail.parse(imap.fetch(message_id, 'RFC822').first.attr['RFC822'])
        mail and mail.dispatch
      rescue => ex
        logger.warn ex
      ensure
        delete_message_id(imap, message_id)
      end

      def delete_message_id(imap, message_id)
        imap.store(message_id, "+FLAGS", [:Deleted])
        logger.debug "Message #{message_id} deleted"
      rescue => ex
        logger.warn ex
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
