require 'test_helper'
require 'basil/servers/mock'

class TestBasil < Test::Unit::TestCase
  def setup
    @server = Config.server

    Plugin.load!
    File.unlink('/tmp/basil.pstore')
  end

  def teardown
    clear_plugins!
  end

  def test_test_plugin
    reply = @server.process('test')

    assert_match /hello world/i, reply.text
  end

  def test_seen_plugin
    @server.process('nope',      :from_name => 'Bill',  :to => 'Fred')
    @server.process('found me',  :from_name => 'Bob',   :to => 'Alice')
    @server.process('me either', :from_name => 'Steve', :to => 'Jim')

    reply = @server.process('seen Bob?')

    assert_match /saying "found me"/, reply.text
  end
end
