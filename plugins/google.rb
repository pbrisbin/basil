Basil.respond_to(/^g(oogle)? (.*)/) {

  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{escape(@match_data[2])}"

  if result = get_json(url)['responseData']['results'].first rescue nil
    @msg.reply "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
  else
    @msg.reply "nothing found."
  end

}.description = 'consults the almighty google'
