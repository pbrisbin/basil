# https://github.com/github/hubot-scripts/blob/master/src/scripts/defprogramming.coffee
Basil::Plugin.respond_to(/^def ?programming$/) {

  begin
    require 'nokogiri'
    html = get_http("http://www.defprogramming.com/random")
    doc = Nokogiri::HTML.parse(html.body)
    quote = doc.search('cite a p')[0].children.to_s

    says quote
  rescue
    nil
  end

}.description = "print a random quote from defprogramming.com"
