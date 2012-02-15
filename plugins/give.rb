Basil.respond_to(/^give (\w+) (.*)/) {

  # form a message to basil without the give
  msg = Basil::Message.new(Basil::Config.me, @msg.from, @msg.from_name, @match_data[2].strip)

  # set the ivar as basil's reply
  @msg = Basil.dispatch(msg)

  # so we can forward it on
  @msg ? forwards_to(@match_data[1]) : nil

}.description = 'executes a plugin replying to someone else'
