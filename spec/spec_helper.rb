require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

# quiet logging during tests
require 'basil/logging'
Basil::Logger.level = ::Logger::FATAL

require 'basil'
