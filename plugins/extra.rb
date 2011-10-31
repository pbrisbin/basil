Basil::Plugin.respond_to(/^(echo|say) (.*)/) {

  says @match_data[2].strip

}.description = "echos what it's told"

Basil::Plugin.respond_to(/^give (\w+) (.*)/) {

  cmd = Basil::Message.new(Basil::Config.me, @match_data[1], @match_data[1], @match_data[2].strip)
  dispatch(cmd)

}.description = 'executes a plugin replying to someone else'

Basil::Plugin.respond_to(/^g(oogle)? (.*)/) {

  require 'cgi'
  require 'json'
  require 'net/http'

  url  = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{CGI::escape(@match_data[2].strip)}"
  resp = Net::HTTP.get_response(URI.parse(url))
  json = JSON.parse(resp.body)

  results = json['responseData']['results'] rescue []

  if results.empty?
    replies "Nothing found."
  else
    result = results.first
    replies "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
  end

}.description = 'consults the almighty google'
