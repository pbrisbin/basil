Basil::Plugin.respond_to(/^test$/) do
  #
  # this block becomes the execute method on the plugin so you have
  # access to all of its instance variables and helper methods
  #
  replies "Hello from #{self.inspect}!"
end
