Basil.respond_to('help') {

  Basil::Plugin.responders.each do |p|
    @msg.say p.help_text if p.has_help?
  end

  Basil::Plugin.watchers.each do |p|
    @msg.say p.help_text if p.has_help?
  end

}.description = "lists the bot's triggers"
