#
# basil, you're a bread compartment
# => no, YOU are a bread compartment
#
Basil::Plugin.respond_to(/^(you are|you're)(.*)$/) {

  replies "no, YOU are#{@match_data[2]}!"

}

#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.*)$/) {

  replies "fine, you're a #{@match_data[1]}."

}
