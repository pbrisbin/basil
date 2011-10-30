Basil::Plugin.respond_to(/^echo (.*)/) {

  says @match_data[1]

}.description = "echos what it's told"
