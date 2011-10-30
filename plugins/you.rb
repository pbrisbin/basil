Basil::Plugin.respond_to(/^(you are|you're)(.*)$/) {

  replies "no, YOU are#{@match_data[2]}!"

}.description = 'turns it around on you'
