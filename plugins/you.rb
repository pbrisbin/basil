#
# basil, you're a bread compartment
# => no, YOU are a bread compartment
#
Basil::Plugin.respond_to(/^you(.*)/) {

  replies "no, YOU#{@match_data[1]}!"

}
