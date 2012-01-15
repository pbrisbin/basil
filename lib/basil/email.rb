require 'net/imap'

module Basil
  # Note: to prevent "catch-up" spam the first time this is enabled or
  # renabled after breaking (say it ain't so!), I recommend clearing
  # the bot's inbox (manually or by running a CLI instance).
  module Email
    # Looping it its own Thread, check the configured email address on
    # the given interval.
    #
    # Implementing the Strategy pattern, you should pass in one or an
    # Array of objects which respond to create_message accepting a
    # Basil::Email::Mail and returning a Basil::Message (or nil).
    #
    # When a strategy object returns a Message, the strategy object and
    # the message are yielded to the block which should handle the
    # server-specific task of sending the message to chat.
    #
    # Note: if multiple strategy objects return Messages for the given
    # Mail, they will all be yielded.
    #
    # Messages are always deleted from the IMAP server after processing,
    # this is to aggressively prevent duplicate processing.
    def self.check_email(interval, strategies, &block)
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

    def self.with_imap(config = Config.email, &block)
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
    private_class_method :with_imap

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

    # An example strategy. We look for subjects that identify build
    # failures and successes coming from Jenkins and format a simple
    # message to be broadcast to the appropriate chat.
    #
    # TODO: the subject lines we're watching for and the chats we send
    # to should be moved to configuration.
    class JenkinsStrategy
      def create_message(mail)
        case mail['Subject'] 
        when /build failed in Jenkins: (\w+) #(\d+)/i
          msg = "(*) #{$1} failed!\nPlease see http://#{Basil::Config.jenkins['host']}/job/#{$1}/#{$2}/changes"
        when /jenkins build is back to normal : (\w+) #(\d+)/i
          msg = "(y) #{$1} is back to normal"
        else
          $stderr.puts "discarding non-matching email (subject: #{mail['Subject']})"
          return nil
        end

        Basil::Message.new(nil, Basil::Config.me, Basil::Config.me, msg)
      end

      def send_to_chat?(topic)
        topic =~ /no more broken builds/i
      end
    end
  end
end
