module Basil
  class SimpleDispatch
    # take a valid message and ask each registered plugin (responders
    # then watchers) if it wishes to act on it. The first reply
    # received is returned, otherwise nil.
    def self.dispatch(msg)
      return nil unless msg && msg.text != ''

      if msg.to_me?
        Plugin.responders.each do |p|
          reply = p.triggered(msg)
          return reply if reply
        end
      end

      Plugin.watchers.each do |p|
        reply = p.triggered(msg)
        return reply if reply
      end

      nil
    end
  end

  class ExtendedDispatch
    def self.dispatch(msg)
      process_pipeline(replace_substitutions(msg))
    end

    private

    # collapse pipe-separated commands to one reply by dispatching
    # each component and feeding the reply of one as argument to the
    # next.
    def self.process_pipeline(msg)
      return SimpleDispatch.dispatch(msg) unless msg.text.include?('|')

      reply    = nil
      commands = msg.text.split('|').map(&:strip)

      while command = commands.shift
        text  = reply ? "#{command} #{reply.text}" : command
        reply = SimpleDispatch.dispatch(Message.new(Config.me, msg.from, msg.from_name, text, msg.chat))

        # invalid component
        return SimpleDispatch.dispatch(msg) unless reply
      end

      reply
    end

    # recursively replace $(...) with the reply returned by
    # dispatching the inner content.
    def self.replace_substitutions(msg)
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
