require 'spec_helper'

module Basil
  describe ChatHistory do
    before do
      @msgs = [ Message.new(:to => 'jim', :from => 'bob', :from_name => 'Bob', :chat => 'chat_a'),
                Message.new(:to => 'bob', :from => 'jim', :from_name => 'Jim', :chat => 'chat_a'),
                Message.new(:to => 'jim', :from => 'bob', :from_name => 'Bob', :chat => 'chat_b'),
                Message.new(:to => 'bob', :from => 'jim', :from_name => 'Jim', :chat => 'chat_b') ]

      @msgs.each { |msg| ChatHistory.store_message(msg) }
    end

    after do
      ChatHistory.clear_history('chat_a')
      ChatHistory.clear_history('chat_b')
    end

    it "can store any object that is coercible to a message" do
      msg = double('msg')
      obj = double('obj', :to_message => msg)

      ChatHistory.should_receive(:store_message).with(msg)

      ChatHistory.store(obj)
    end

    it "can fetch messages for a chat" do
      msgs = ChatHistory.get_messages('chat_a')
      msgs.should == [@msgs[1], @msgs[0]]

      msgs = ChatHistory.get_messages('chat_b')
      msgs.should == [@msgs[3], @msgs[2]]
    end

    it "can fetch messages to someone" do
      msgs = ChatHistory.get_messages('chat_a', :to => 'Jim')
      msgs.should == [@msgs[0]]
    end

    it "can fetch messages from someone" do
      msgs = ChatHistory.get_messages('chat_a', :from => 'Jim')
      msgs.should == [@msgs[1]]
    end

    it "can purge chat history" do
      ChatHistory.clear_history('chat_a')
      ChatHistory.get_messages('chat_a').should be_empty
      ChatHistory.get_messages('chat_b').should_not be_empty
    end
  end
end
