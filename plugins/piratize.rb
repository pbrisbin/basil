Basil.respond_to(/piratize (.+)/) do
  if text = get_html("http://postlikeapirate.com/AJAXtranslate.php?typing=#{escape(@match_data[1])}")
    says text
  end
end
