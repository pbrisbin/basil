Basil::Plugin.respond_to(/^g(oogle)? *(.*)$/) {

  require 'nokogiri'
  require 'open-uri'

  url = "http://www.google.com/search?q=#{@match_data[2]}"
  doc = Nokogiri::HTML(open(url))

  links = doc.css('h3.r a.l')
  
  if links.empty?
    replies "Nothing found."
  else
    link = links.first
    replies "#{link['href']} - #{link.content}"
  end

}.description 'googles for some phrase'
