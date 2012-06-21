require 'spec_helper'

module Basil
  describe ChatHistory do
    before do
      @store = {} # simple hash
      Storage.stub(:with_storage).and_yield(@store)

      class MyPlugin
        include Logging
        include ChatHistory

        attr_accessor :msg
      end

      @plugin = MyPlugin.new

      # fake some conversations
      @msgs = [ Message.new('jim', 'bob', 'Bob', 'A message', 'chat_a'),
                Message.new('bob', 'jim', 'Jim', 'A message', 'chat_a'),
                Message.new('jim', 'bob', 'Bob', 'Another message', 'chat_b'),
                Message.new('bob', 'jim', 'Jim', 'Another message', 'chat_b') ]

      # store all our sample messages
      @msgs.each { |msg| ChatHistory.store_message(msg) }

      # make it so we're "in" chat_a
      @plugin.msg = double('msg', :chat => 'chat_a')
    end

    it "can fetch messages for this chat" do
      @plugin.chat_history.should == [@msgs[1], @msgs[0]]
    end

    it "can fetch messages to someone" do
      @plugin.chat_history(:to => 'Jim').should == [@msgs[0]]

    end

    it "can fetch messages from someone" do
      @plugin.chat_history(:from => 'Jim').should == [@msgs[1]]
    end

    it "can fetch for another chat" do
      @plugin.chat_history(:chat => 'chat_b').should == [@msgs[3], @msgs[2]]
    end

    it "can purge chat history" do
      @plugin.purge_history!
      @plugin.chat_history.should be_empty
      @plugin.chat_history(:chat => 'chat_b').should_not be_empty
    end
  end
end
