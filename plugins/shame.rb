Basil.respond_to(/^shame *(.+)/) {

  @msg.say "For shame #{@match_data[1]}, FOR SHAME!"

}.description = 'publicly shame someone or something'
