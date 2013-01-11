module Basil
  module Email
    # This class represents a parsed email. Headers are accessed like
    # array indices and body is provided as a method. The parsing is
    # naive, but it works for our purpose.
    class Mail
      attr_reader :body

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

      def initialize(headers, body)
        @headers, @body = headers, body
      end

      def [](arg)
        @headers[arg]
      end

      # TODO: Mail is /kind of/ quacking like a Message here, but not
      # quite. should think about DRYing this up somehow.
      def dispatch(server)
        Plugin.email_checkers.each do |p|
          if p.regex =~ self['Subject']
            msg = Message.new(:to => Config.me, :from => self['From'], :text => body)
            msg.server = server

            p.set_context(msg, $~)
            p.execute
          end
        end
      end

      def to_s
        "#<Mail from: #{self['From']}, subject: #{self['Subject']} >"
      end

    end
  end
end
