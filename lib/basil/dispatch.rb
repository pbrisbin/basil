module Basil
  class Dispatch
    class << self
      # take a valid message and ask each registered plugin (responders
      # then watchers) if it wishes to act on it. The first reply
      # received is returned, otherwise nil.
      def simple(msg)
        if msg.to_me?
          logger.debug 'Responders'
          if reply = dispatch_through(Plugin.responders, msg)
            return reply
          end
        end

        logger.debug 'Watchers'
        dispatch_through(Plugin.watchers, msg)
      end

      def extended(msg)
        ensure_valid(process_pipeline(replace_substitutions(msg)))
      end

      def email(mail)
        dispatch_through(Plugin.email_checkers, mail)
      end

      private

      def dispatch_through(plugins, msg)
        plugins.each do |p|
          if reply = p.triggered?(msg)
            logger.info "#{p} triggered"
            return ensure_valid(reply)
          end
        end

        logger.debug 'No response'

        nil
      end

      # dispatching must return a Message or nil, anything else will
      # cause errors.
      def ensure_valid(obj)
        return obj if obj.nil? || obj.is_a?(Message)

        logger.warn "Invalid object returned"
        logger.warn obj

        nil
      end

      # collapse pipe-separated commands to one reply by dispatching
      # each component and feeding the reply of one as argument to the
      # next.
      def process_pipeline(msg)
        return simple(msg) unless msg.text.include?('|')

        reply    = nil
        commands = msg.text.split('|').map(&:strip)

        while command = commands.shift
          text  = reply ? "#{command} #{reply.text}" : command
          reply = simple(Message.from_message(msg, :to => Config.me, :text => text))

          # invalid component
          return simple(msg) unless reply
        end

        reply
      end

      # recursively replace $(...) with the reply returned by
      # dispatching the inner content.
      def replace_substitutions(msg)
        while m = /(.*)\$\((.*)\)(.*)/.match(msg.text)
          pref, sub, suf = m.captures

          # handle pipelines inside substitutions
          reply = process_pipeline(Message.from_message(msg, :to => Config.me, :text => sub))

          # invalid component
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
