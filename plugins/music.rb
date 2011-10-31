Basil::Plugin.respond_to(/^mpc.*/) {

  require_authorization do
    out = `#{@match_data[0]} 2>&1`
    msg = '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'

    if $? == 0
      says [out, msg].join("\n")
    else
      says out
    end
  end
  
}.description = "controls the server's music stream"

#
# http://kmkeen.com/albumbler/
#
Basil::Plugin.respond_to('albumbler') {

  says `#{@match_data[0]} 2>&1`

}.description = 'chooses an album to play based on historical use data'
