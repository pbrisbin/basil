Basil.respond_to(/piratize (.+)/) {

  url = "http://postlikeapirate.com/AJAXtranslate.php?typing=#{escape(@match_data[1])}"
  @msg.say get_html(url).css('p').first.content

}
