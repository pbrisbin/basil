Basil.respond_to('help') {

  says do |out|
    Basil::Plugin.responders.each do |p|
      next unless p.description
      out << "#{p.regex.inspect} => #{p.description}."
    end

    Basil::Plugin.watchers.each do |p|
      next unless p.description
      out << "#{p.regex.inspect} => #{p.description}."
    end
  end

}.description = "lists the bot's triggers"
