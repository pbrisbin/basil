Basil::Plugin.respond_to(/^reload$/) {

  Basil::Plugin.load!(true)
  replies 'done.'

}.description = 'reloads all files in the plugins directory'
