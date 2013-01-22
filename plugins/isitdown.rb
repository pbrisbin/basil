Basil.respond_to(/^is (\S+) down\??$/) {

  text = get_html("http://www.isup.me/#{@match_data[1]}").at('#container').children.to_s

  @msg.say text.strip.split("\n").first.strip.gsub(/<\/?a.*?>/, '')

}.description = "see if a site is down for everyone or just you"
