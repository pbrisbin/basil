module Basil
  class Dispatch
    class << self
      include Logging

      # take a valid message and ask each registered plugin (responders
      # then watchers) if it wishes to act on it. The first reply
      # received is returned, otherwise nil.
      def simple(msg)
        return nil unless msg && msg.text != ''

        if msg.to_me?
          if reply = dispatch_through(Plugin.responders, msg)
            return reply
          end
        end

        dispatch_through(Plugin.watchers, msg)
      end

      def extended(msg)
        return nil unless msg && msg.text != ''

        ensure_valid(process_pipeline(replace_substitutions(msg)))
      end

      def email(mail)
        return nil unless mail && mail['Subject']

        dispatch_through(Plugin.email_checkers, mail)
      end

      private

      def dispatch_through(plugins, msg)
        plugins.each do |p|
          if reply = p.triggered?(msg)
            info "#{p.pretty} triggered"
            return ensure_valid(reply)
          end
        end

        nil
      end

      # dispatching must return a Message or nil, anything else will
      # cause errors.
      def ensure_valid(obj)
        return obj if obj.nil? || obj.is_a?(Message)

        error "invalid object <#{obj}>, expected Message or nil"

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
          reply = simple(Message.new(Config.me, msg.from, msg.from_name, text, msg.chat))

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
          reply = process_pipeline(Message.new(Config.me, msg.from, msg.from_name, sub, msg.chat))

          # invalid component
          return msg unless reply

          msg = Message.new(Config.me, msg.from, msg.from_name, "#{pref}#{reply.text}#{suf}", msg.chat)
        end

        msg
      end
    end
  end
end
