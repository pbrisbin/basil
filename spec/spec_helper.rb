require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'basil'

# quiet logging during tests
Basil::Logger.level = ::Logger::FATAL
