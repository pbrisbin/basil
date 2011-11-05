require 'test_helper'

class TestPlugins < Test::Unit::TestCase
  include Basil

  def teardown
    Plugin.responders.delete_if { true }
    Plugin.watchers.delete_if { true }
  end

  def test_register_responder
    p = Plugin.respond_to('') { nil }

    assert Plugin.watchers.empty?, "plugin should not be a watcher"
    assert_equal [p], Plugin.responders, "plugin should be a responder"
  end

  def test_register_watcher
    p = Plugin.watch_for('') { nil }

    assert Plugin.responders.empty?, "plugin should not be a responder"
    assert_equal [p], Plugin.watchers, "plugin should be a watcher"
  end

  def test_respond_to
    Plugin.respond_to('test') { true }
    assert dispatch(Message.new(Config.me, nil, nil, 'test')), "Message should trigger"
    assert !dispatch(Message.new(nil, nil, nil, 'test')), "Message not to me shouldn't trigger"
    assert !dispatch(Message.new(Config.me, nil, nil, 'foo')), "Other Message shouldn't trigger"

    Plugin.respond_to(/test (A|B)/) { true }
    assert dispatch(Message.new(Config.me, nil, nil, 'test A')), "Message A should trigger"
    assert dispatch(Message.new(Config.me, nil, nil, 'test B')), "Message B should trigger"
    assert !dispatch(Message.new(nil, nil, nil, 'test A')), "Message not to me shouldn't trigger"
    assert !dispatch(Message.new(Config.me, nil, nil, 'foo')), "Other Message shouldn't trigger"
  end

  def test_watch_for
    Plugin.watch_for('test') { true }
    assert dispatch(Message.new(nil, nil, nil, 'test')), "Message should trigger"
    assert !dispatch(Message.new(nil, nil, nil, 'foo')), "Other Message shouldn't trigger"

    Plugin.watch_for(/test (A|B)/) { true }
    assert dispatch(Message.new(nil, nil, nil, 'test A')), "Message A should trigger"
    assert dispatch(Message.new(nil, nil, nil, 'test B')), "Message B should trigger"
    assert !dispatch(Message.new(nil, nil, nil, 'foo')), "Other Message shouldn't trigger"
  end

  def test_instance_variables
    msg = Message.new(Config.me, nil, nil, 'test text')

    Plugin.respond_to(/test (.*)/) {
      return false unless @msg == msg
      return false unless @match_data[0] == 'test text'
      return false unless @match_data[1] == 'text'
      return false unless @match_data[2].nil?

      true
    }

    assert dispatch(msg)

    msg = Message.new(nil, nil, nil, 'test text')

    Plugin.watch_for(/test (.*)/) {
      return false unless @msg == msg
      return false unless @match_data[0] == 'test text'
      return false unless @match_data[1] == 'text'

      true
    }

    assert dispatch(msg)
  end

  def test_dispatch
    Plugin.respond_to('test') { :responder }
    Plugin.watch_for('test')  { :watcher   }

    msg = Message.new(Config.me, nil, nil, 'test')
    assert_equal :responder, dispatch(msg), "Responder should respond"

    msg = Message.new(nil, nil, nil, 'test')
    assert_equal :watcher, dispatch(msg), "Watcher should respond"

    msg = Message.new(Config.me, nil, nil, 'foo')
    assert_nil dispatch(msg), "No one should respond"

    msg = Message.new(nil, nil, nil, 'foo')
    assert_nil dispatch(msg), "No one should respond"
  end

  def test_dispatch_order
    Plugin.watch_for(/tester/) { :p1 }
    Plugin.watch_for(/teste/)  { :p2 }
    Plugin.watch_for(/test/)   { :p3 }

    msg = Message.new(nil, nil, nil, 'tester')
    assert_equal :p1, dispatch(msg), "First plugin should handle it"

    msg = Message.new(nil, nil, nil, 'teste')
    assert_equal :p2, dispatch(msg), "Second plugin should handle it"

    msg = Message.new(nil, nil, nil, 'test')
    assert_equal :p3, dispatch(msg), "Third plugin should handle it"

    msg = Message.new(nil, nil, nil, 'tes')
    assert_nil dispatch(msg), "No one should handle it"
  end
end
