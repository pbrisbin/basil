Basil::Plugin.respond_to(/^(echo|say) (.*)/) {

  says @match_data[2].strip.sub(/^Basil\s+is\b/, 'I am')

}.description = "echos what it's told"

Basil::Plugin.respond_to(/^give (\w+) (.*)/) {

  cmd = Basil::Message.new(Basil::Config.me, @match_data[1], @match_data[1], @match_data[2].strip)
  dispatch(cmd)

}.description = 'executes a plugin replying to someone else'

Basil::Plugin.respond_to(/^g(oogle)? (.*)/) {

  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{escape(@match_data[2])}"

  if result = get_json(url)['responseData']['results'].first rescue nil
    replies "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
  else
    replies "Nothing found."
  end

}.description = 'consults the almighty google'
