Basil::Plugin.respond_to(/^mpc ?.*/) {

  out = `#{@match_data[0]} 2>&1`
  msg = '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'

  if $? == 0
    says [out, msg].join("\n")
  else
    says out
  end
  
}.description = "controls the server's music stream"
