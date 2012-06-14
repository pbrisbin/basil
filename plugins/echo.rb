Basil.respond_to(/^(echo|say) (.*)/) {

  says @match_data[2]

}.description = "says what it's told"
