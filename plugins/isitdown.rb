Basil.respond_to(/^is (\S+) down\??$/) {

  text = get_html("http://www.isup.me/#{@match_data[1]}").at('#container').children.to_s rescue nil

  # note, relying on assumptions about this sites html...
  if text && text =~ /\n *\n(.*)\n/; says $1.gsub(/<\/?a.*?>/, '') else nil end

}.description = "see if a site is down for everyone or just you"
