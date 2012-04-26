module Basil
  class Readline
    class << self
      # A drop-in for Basil.dispatch. Handles command substitution and
      # pipelining. If one of the components is not a valid basil
      # command, the full line is simply dispatched as-is.
      def dispatch(msg)
        process_pipeline(replace_substitutions(msg))
      rescue
        Basil.dispatch(msg)
      end

      # recursively replace $(...) with the reply returned by
      # dispatching the inner content.
      def replace_substitutions(msg)
        while m = /(.*)\$\((.*)\)(.*)/.match(msg.text)
          pref, sub, suf = m.captures

          # handle pipelines inside substitutions
          reply = process_pipeline(Message.new(Config.me, msg.from, msg.from_name, sub, msg.chat))

          # invalid component
          raise unless reply

          msg = Message.new(Config.me, msg.from, msg.from_name, "#{pref}#{reply.text}#{suf}", msg.chat)
        end

        msg
      end

      # collapse pipe-separated commands to one reply by dispatching
      # each component and feeding the reply of one as argument to the
      # next.
      def process_pipeline(msg)
        return Basil.dispatch(msg) unless msg.text.include?('|')

        reply    = nil
        commands = msg.text.split('|').map(&:strip)

        while command = commands.shift
          text  = reply ? "#{command} #{reply.text}" : command
          reply = Basil.dispatch(Message.new(Config.me, msg.from, msg.from_name, text, msg.chat))

          # invalid component
          return Basil.dipatch(msg) unless reply
        end

        reply
      end
    end
  end
end
