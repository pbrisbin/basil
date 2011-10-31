#
# Simple echo
#
Basil::Plugin.respond_to(/^echo (.*)/) {

  says @match_data[1]

}.description = "echos what it's told"

#
# Todo: provide an "alias" helper for times like these
#
Basil::Plugin.respond_to(/^say (.*)/) {

  says @match_data[1]

}.description = 'an alias for echo'

#
# Gives a reply to someone else
#
Basil::Plugin.respond_to(/^give (\w+) (.*)$/) {

  cmd = Basil::Message.new(Basil::Config.me, @match_data[1], @match_data[2])
  dispatch(cmd)

}.description = 'executes a plugin replying to someone else'

#
# Google for something
#
Basil::Plugin.respond_to(/^g(oogle)? *(.*)$/) {

  require 'cgi'
  require 'json'
  require 'net/http'

  url  = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{CGI::escape(@match_data[2])}"
  resp = Net::HTTP.get_response(URI.parse(url))
  json = JSON.parse(resp.body)

  results = json['responseData']['results'] rescue []

  if results.empty?
    replies "Nothing found."
  else
    result = results.first
    replies "#{result['titleNoFormatting']}: #{result['unescapedUrl']}"
  end

}.description = 'googles for some phrase'
