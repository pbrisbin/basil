module Basil
  module Email
    # This class represents a parsed email. Headers are accessed like
    # array indices and body is provided as a method. The parsing is
    # naive, but it works for our purpose.
    class Mail
      include Dispatchable

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

      def each_plugin(&block)
        Plugin.email_checkers.each(&block)
      end

      def match?(plugin)
        plugin.regex.match(self['Subject'])
      end

      def to_message
        Message.new(
          :to   => Config.me,
          :from => self['From'],
          :text => body
        )
      end

      def to_s
        "#<Mail from: #{self['From']}, subject: #{self['Subject']} >"
      end

    end
  end
end
