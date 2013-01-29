module Messages
  class << self

    def leave(to, from, message)
      with_messages do |messages|
        messages << {
          :time     => Time.now,
          :to       => to,
          :from     => from,
          :message  => message,
          :notified => false
        }
      end
    end

    def check(name)
      with_messages do |messages|
        my_messages = messages.select do |message|
          name =~ /#{message[:to]}/i
        end

        my_messages.each do |message|
          messages.delete(message)
        end

        my_messages
      end
    end

    def any?(name)
      with_messages do |messages|
        any = false

        messages.each do |message|
          if !message[:notified] && name =~ /#{message[:to]}/i
            any = message[:notified] = true
          end
        end

        any
      end
    end

    private

    def with_messages
      Basil::Storage.with_storage do |store|
        yield(store[:tell_messages] ||= [])
      end
    end

  end
end

Basil.respond_to(/^tell ([^:]*): (.+)/) {

  Messages.leave(@match_data[1], @msg.from_name, @match_data[2])

  @msg.reply "consider it noted."

}.description = "Leave a message for someone"

Basil.respond_to(/^(do i have any |any )?messages\??$/i) {

  messages = Messages.check(@msg.from_name)

  if messages.any?
    @msg.reply 'your messages:'

    messages.each do |msg|
      @msg.say trim(<<-EOM)
        #{msg[:time].strftime("On %D, at %r")}, #{msg[:from]} wrote:
        > #{msg[:message]}
      EOM
    end
  else
    @msg.reply 'no messages.'
  end

}.description = "See if anyone's left you a message"

Basil.watch_for(/.*/) {

  if Messages.any?(@msg.from_name)
    @msg.reply "someone's left you a message. say 'messages?' to me to check them."
  end

}
