Basil.respond_to('help') {

  Basil::Plugin.responders.each do |p|
    next unless p.description
    @msg.say "#{p.regex.inspect} => #{p.description}."
  end

  Basil::Plugin.watchers.each do |p|
    next unless p.description
    @msg.say "#{p.regex.inspect} => #{p.description}."
  end

}.description = "lists the bot's triggers"
