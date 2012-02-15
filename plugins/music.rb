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
#   mpc load <playlist>
#   mpc stats
#   mpc version
#
Basil.respond_to(/^mpc load (.*)$/) {

  list = @match_data[1].strip rescue nil
  available = `mpc lsplaylists`.split("\n")

  if list && list != '' && available.include?(list)
    says do |out|
      out << `mpc load #{list}`
      out << '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'
    end
  else
    raise 'playlist not found or not given'
  end

}

Basil.respond_to(/^mpc( (.*))?$/) {

  arg = @match_data[2].strip rescue nil
  valid_args = %w{ current play next prev pause toggle playlist
                   lsplaylists stats version }

  if !arg || arg == '' || valid_args.include?(arg)
    says do |out|
      out << `#{@match_data[0]}`
      out << '-- listen at http://pbrisbin.com:8000/mpd.mp3 --'
    end
  else
    # to match mpc help order
    valid_args.insert(8, 'load <playlist>')
    says "usage: mpc [#{valid_args.join('|')}]"
  end

}

#
# http://kmkeen.com/albumbler/
#
Basil.respond_to('albumbler') {

  says `#{@match_data[0]} 2>&1`

}
