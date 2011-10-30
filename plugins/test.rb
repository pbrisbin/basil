Basil::Plugin.respond_to(/^test$/) {

  replies "Hello world from #{self.inspect}!"

}.description = 'tests that the bot is working'
