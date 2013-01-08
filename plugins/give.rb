Basil.respond_to(/^give (\w+) (.*)/) {

  msg = Basil::Message.from_message(@msg, :text => @match_data[2].strip)

  if reply = Basil::Config.server.dispatch_message(msg)
    reply.to = @match_data[1]
  end

  reply

}.description = 'executes a plugin replying to someone else'
