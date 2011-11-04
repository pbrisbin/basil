#
# basil, you're a bread compartment
# => no, YOU are a bread compartment
#
Basil::Plugin.respond_to(/^you(.*)/) {

  replies "no, YOU#{@match_data[1]}!"

}

#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.*)/) {

  replies "fine, you're a #{@match_data[1]}."

}

Basil::Plugin.respond_to('beer') {

  replies "someone wanted you to have this (beer)"

}
