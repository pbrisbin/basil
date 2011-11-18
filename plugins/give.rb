Basil::Plugin.respond_to(/^give (\w+) (.*)/) {

  msg = Basil::Message.new(Basil::Config.me, @match_data[1], @match_data[1], @match_data[2].strip)
  Basil.dispatch(msg)

}.description = 'executes a plugin replying to someone else'
