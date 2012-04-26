require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'basil'
require 'mocha'

class Test::Unit::TestCase
  include Basil

  Config.config_file = './config/test.yml'

  def clear_plugins!
    Plugin.responders.delete_if { true }
    Plugin.watchers.delete_if { true }
  end

  def clear_storage!
    file = Storage.pstore_file

    File.unlink(file) if File.exists?(file)
  end
end
