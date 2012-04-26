Basil.respond_to(/^(echo|say) (.*)/) {

  says @match_data[2].strip.sub(/^basil\s+is\b/i, 'I am')

}.description = "says what it's told"
