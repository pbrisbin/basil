Basil::Plugin.respond_to('reload') {

  a = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.responders.delete_if { true }
  Basil::Plugin.watchers.delete_if   { true }

  b = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.load!

  c = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  says "#{a - b} plugins removed, #{c - b} plugins (re)loaded."

}.description = 'reloads all plugins'
