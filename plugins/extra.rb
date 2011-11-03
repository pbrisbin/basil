Basil::Plugin.respond_to(/^(echo|say) (.*)/) {

  says @match_data[2].strip

}.description = "echos what it's told"

Basil::Plugin.respond_to(/^give (\w+) (.*)/) {

  cmd = Basil::Message.new(Basil::Config.me, @match_data[1], @match_data[1], @match_data[2].strip)
  dispatch(cmd)

}.description = 'executes a plugin replying to someone else'

Basil::Plugin.respond_to(/^g(oogle)? (.*)/) {

  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{escape(@match_data[2])}"

  if json = get_json(url)
    result = json['responseData']['results'].first rescue nil

    if result
      replies "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
    else
      replies "Nothing found."
    end
  end

}.description = 'consults the almighty google'
