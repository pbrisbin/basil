#
# Supported actions:
#
#   mpc
#   mpc current
#   mpc play
#   mpc next
#   mpc prev
#   mpc pause
#   mpc toggle
#   mpc playlist
#   mpc lsplaylists
#   mpc load <file>
#   mpc stats
#   mpc version
#
Basil::Plugin.respond_to(/^mpc load (.*)$/) {

  file = @match_data[1].strip rescue nil

  if file && file != '' && File.exists?(file)
    out = `mpc load #{file}`
    msg = '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'

    says [out, msg].join("\n")
  else
    raise 'playlist file not found or not given'
  end

}

Basil::Plugin.respond_to(/^mpc( (.*))?$/) {

  arg = @match_data[2].strip rescue nil

  valid_args = %w{ current play next prev pause toggle playlist
                   lsplaylists stats version }

  if !arg || arg == '' || valid_args.include?(arg)
    out = `#{@match_data[0]}`
    msg = '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'

    says [out, msg].join("\n")
  else
    # to match mpc help order
    valid_args.insert(8, 'load <file>')
    says "usage: mpc [#{valid_args.join('|')}]"
  end

}

#
# http://kmkeen.com/albumbler/
#
Basil::Plugin.respond_to('albumbler') {

  says `#{@match_data[0]} 2>&1`

}
