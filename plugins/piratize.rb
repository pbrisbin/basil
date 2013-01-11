Basil.respond_to(/piratize (.+)/) do
  text = get_html("http://postlikeapirate.com/AJAXtranslate.php?typing=#{escape(@match_data[1])}") rescue nil
  @msg.say text.css('p').first.content if text
end
