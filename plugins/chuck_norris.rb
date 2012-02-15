Basil.watch_for(/(chuck norris|jack bauer)/i) {

  query = @match_data[0].downcase == 'jack bauer' ?  '?firstName=Jack&lastName=Bauer' : ''

  says get_json("http://api.icndb.com/jokes/random#{query}")['value']['joke'] rescue nil

}
