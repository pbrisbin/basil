#
# basil, you're a bread compartment
# => no, YOU are a bread compartment
#
Basil.respond_to(/^you(.*)/) {

  @msg.reply "no, YOU#{@match_data[1]}!"

}
