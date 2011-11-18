#
# basil, call me a taxi
# => fine, you're a taxi.
#
Basil::Plugin.respond_to(/^call me a (.*)/) {

  says "fine, you're a #{@match_data[1]}."

}
