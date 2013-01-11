Basil.respond_to(/^(echo|say) (.*)/) {

  @msg.say @match_data[2]

}.description = "says what it's told"
