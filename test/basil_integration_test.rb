require 'test_helper'
require 'basil/servers/mock'

class TestMessage < Test::Unit::TestCase
  def setup
    Plugin.load!

    @server = Config.server
  end

  def teardown
    clear_plugins!
  end

  def test_test_plugin
    reply = @server.process('test')

    assert_match /hello world/i, reply.text
  end
end
