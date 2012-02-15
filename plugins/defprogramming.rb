# https://github.com/github/hubot-scripts/blob/master/src/scripts/defprogramming.coffee
Basil.respond_to(/^def ?programming$/) {

  quote = get_html("http://www.defprogramming.com/random").search('cite a p')[0].children.to_s rescue nil
  says quote if quote

}.description = "print a random quote from defprogramming.com"
