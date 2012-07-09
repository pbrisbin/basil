Basil.respond_to(/^shame *(.+)/) {

  says "For shame #{@match_data[1]}, FOR SHAME!"

}.description = 'publicly shame someone or something'
