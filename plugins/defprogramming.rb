# https://github.com/github/hubot-scripts/blob/master/src/scripts/defprogramming.coffee
Basil.respond_to(/^def ?programming$/) {

  @msg.say get_html("http://www.defprogramming.com/random").search('cite a p').first.children.to_s

}.description = "print a random quote from defprogramming.com"
