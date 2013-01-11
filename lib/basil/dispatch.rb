module Basil
  module Dispatch
    class << self

      def process(msg)
        extended? ? extended(msg) : simple(msg)
      end

      private

      def extended?
        Config.dispatch_type == :extended
      end

      def extended(msg)
        ensure_valid(
          process_pipeline(
            replace_substitutions(msg)
        ))
      end

      def simple(msg)
        msg.dispatch
      end

      def ensure_valid(obj)
        return obj if obj.nil? || obj.is_a?(Message)

        logger.warn "Invalid object returned"
        logger.warn obj

        nil
      end

      def process_pipeline(msg)
        return simple(msg) unless msg.text.include?('|')

        reply    = nil
        commands = msg.text.split('|').map(&:strip)

        while command = commands.shift
          text  = reply ? "#{command} #{reply.text}" : command
          reply = simple(Message.from_message(msg, :to => Config.me, :text => text))

          return simple(msg) unless reply
        end

        reply
      end

      def replace_substitutions(msg)
        while m = /(.*)\$\((.*)\)(.*)/.match(msg.text)
          pref, sub, suf = m.captures

          reply = process_pipeline(Message.from_message(msg, :to => Config.me, :text => sub))

          return msg unless reply

          msg = Message.from_message(msg, :to => Config.me, :text => "#{pref}#{reply.text}#{suf}")
        end

        msg
      end

      def logger
        @logger ||= Loggers['dispatching']
      end
    end

  end
end
