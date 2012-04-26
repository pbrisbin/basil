require 'test_helper'

class TestReadline< Test::Unit::TestCase
  def setup
    # a single echo plugin for testing
    Basil.respond_to(/^echo (.+)/) { says @match_data[1] }
  end

  def test_normal_dispatch
    assert_echos 'foo'                           # nothing required
    assert_echos 'foo $(blek) bar'               # invalid substitution
    assert_echos 'foo | blek | echo baz'         # invalid pipe-line
    assert_echos 'foo | echo $(blek) | echo'     # invalid sub in a valid pipeline
    assert_echos 'foo | echo $(echo bar) | blek' # invalid pipe-line with a valid sub
  end

  def test_subbed_commands
    assert_dispatched 'echo $(echo foo)', 'foo'
    assert_dispatched 'echo $(echo $(echo foo) bar) baz', 'foo bar baz'
    assert_dispatched 'echo $(echo foo) bar $(echo baz)', 'foo bar baz'
  end

  def test_pipe_commands
    assert_dispatched 'echo foo | echo', 'foo'
    assert_dispatched 'echo foo | echo bar | echo baz', 'baz bar foo'
  end

  def test_piped_and_subbed_commands
    assert_dispatched 'echo $(echo foo | echo bar) baz', 'bar foo baz'
    assert_dispatched 'echo $(echo foo | echo) | echo bar', 'bar foo'
  end

  private

  def assert_dispatched(text, reply)
    msg = Message.new(Config.me, 'f', 'fn', text)

    assert_not_nil (resp = Readline.dispatch(msg)),
      "Given #{msg.text}, Basil should've said something"

    assert_equal reply, resp.text,
      "Given #{msg.text}, Basil should've said #{reply}"
  end

  def assert_echos(text)
    assert_dispatched("echo #{text}", text)
  end
end
