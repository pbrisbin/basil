require 'test_helper'

class TestChatHistory< Test::Unit::TestCase
  include Basil
  include ChatHistory

  def setup
    # makes it as if we're in the 'testing' chat
    @msg = Message.new('to', 'from', 'from_name', 'text', 'testing')
  end

  def teardown
    File.unlink('/tmp/basil.pstore')
  end

  def test_chat_history
    # two message logged "here" and one logged elsewhere
    msg_1 = Message.new('to_a', 'from_a', 'from_name_a', 'text 1', 'testing')
    msg_2 = Message.new('to_b', 'from_b', 'from_name_b', 'text 2', 'NOT testing')
    msg_3 = Message.new('to_c', 'from_c', 'from_name_c', 'text 3', 'testing')

    [msg_1, msg_2, msg_3].each do |msg|
      ChatHistory.store_message(msg)
    end

    assert_equal 2, chat_history.length,
      "2 chats should be logged for this chat"

    assert_equal 1, chat_history(:to => 'to_c').length,
      "1 chat should be logged to 'to_c'"

    assert_equal 1, chat_history(:chat => 'NOT testing', :from => 'from_name_b').length,
      "1 chat should be logged from 'from_name_b' in the other chat"

    assert_equal 0, chat_history(:from => 'from_name_b').length,
      "No chats should be logged from 'from_name_b' in this chat"
  end
end
