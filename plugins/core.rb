#
# Tests that basil is working
#
Basil::Plugin.respond_to(/^test$/) {

  replies "Hello world from #{self.inspect}!"

}.description = 'tests that the bot is working'

#
# Convenient for adjusting/adding plugins without restarting basil
#
Basil::Plugin.respond_to(/^reload$/) {

  Basil::Plugin.class_eval do
    @@responders = nil
    @@watchers   = nil
  end

  Basil::Plugin.load!

  replies 'done.'

}.description = 'reloads all files in the plugins directory'
