Basil.respond_to(/^give (\w+) (.*)/) {

  Basil::Message.from_message(
    @msg,
    :from      => @match_data[1],
    :from_name => @match_data[1],
    :text      => @match_data[2].strip
  ).dispatch

}.description = 'executes a plugin replying to someone else'
