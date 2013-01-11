Basil.respond_to(/^tell ([^:]*): (.+)/) {

  to   = @match_data[1]
  from = @msg.from_name
  msg  = @match_data[2]

  Basil::Storage.with_storage do |store|
    store[:tell_messages] ||= []
    store[:tell_messages] << { :time => Time.now, :to => to, :from => from, :message => msg }
  end

  @msg.reply "consider it noted."

}.description = "Leave a message for someone"

Basil.respond_to(/^(do i have any |any )?messages\??$/i) {

  Basil::Storage.with_storage do |store|
    store[:tell_messages] ||= []
    store[:tell_notified] ||= {}

    msgs = store[:tell_messages].select { |msg| @msg.from_name =~ /#{msg[:to]}/i }

    if msgs.empty?
      @msg.reply "sorry, I have no messages for you."
    else
      store[:tell_notified][@msg.from] = false

      @msg.reply 'your messages:'

      msgs.each do |msg|
        @msg.say "#{msg[:time].strftime("On %D, at %r")}, #{msg[:from]} wrote:"
        @msg.say '> ' + msg[:message]
        @msg.say ''

        # remove the message
        store[:tell_messages].delete(msg)
      end
    end
  end

}.description = "See if anyone's left you a message"

Basil.watch_for(/.*/) {

  msgs = notified = nil

  Basil::Storage.with_storage do |store|
    store[:tell_messages] ||= []
    store[:tell_notified] ||= {}

    msgs = store[:tell_messages].select { |msg| @msg.from_name =~ /#{msg[:to]}/i }
    notified = store[:tell_notified][@msg.from]
  end

  if !msgs.nil? && !msgs.empty? && !notified
    Basil::Storage.with_storage do |store|
      store[:tell_notified][@msg.from] = true
    end

    len = msgs.length

    # plularize correctly
    if len == 1
      @msg.reply "you have #{len} message, say 'messages?' to me to see it."
    else
      @msg.reply "you have #{len} messages, say 'messages?' to me to see them."
    end
  end

}
