#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil.respond_to(/^call me a (.*)/) {

  @msg.say "fine, you're a #{@match_data[1]}."

}
