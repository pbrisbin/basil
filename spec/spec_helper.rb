require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'basil'

Basil::Loggers.level = 6 # OFF
