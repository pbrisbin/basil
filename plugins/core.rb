#
# Tests that basil is working
#
Basil::Plugin.respond_to(/^test$/) {

  replies "Hello world from #{self.inspect}!"

}.description = 'tests that the bot is working'

#
# Show a link to my source
#
Basil::Plugin.respond_to(/^source$/) {

  replies "https://github.com/pbrisbin/basil"

}

#
# Lists out regex/description for everythign basil will respond to / is
# watching for in the chat
#
Basil::Plugin.respond_to(/^help$/) {

  out = []

  Basil::Plugin.responders.each do |p|
    next unless p.description
    out << "#{p.regex.inspect} => #{p.description}."
  end

  Basil::Plugin.watchers.each do |p|
    next unless p.description
    out << "#{p.regex.inspect} => #{p.description}."
  end

  says out.join("\n") unless out.empty?

}

#
# Convenient for adjusting/adding plugins without restarting basil
#
Basil::Plugin.respond_to(/^reload$/) {

  a = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.responders.delete_if { true }
  Basil::Plugin.watchers.delete_if { true }

  b = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.load!

  c = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  replies "#{a - b} plugins removed, #{c - b} plugins (re)loaded."

}.description = 'reloads all files in the plugins directory'
