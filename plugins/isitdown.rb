Basil::Plugin.respond_to(/^is ([^\s]+) down\??$/) {

  text = get_html("http://www.isup.me/#{@match_data[1]}").at('#container').children.to_s rescue ''

  # note, relying on assumptions about this sites html...
  if text =~ /\n *\n(.*)\n/; says $1.gsub(/<\/?a.*?>/, '') else nil end

}.description = "see if a site is down for everyone or just you"
