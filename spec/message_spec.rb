require 'spec_helper'

module Basil
  describe Message do
    it "should raise when from is not given" do
      lambda { Message.new(:to => 'you') }.should raise_error(ArgumentError)
    end

    it "can be constructed with only from" do
      msg = Message.new(:from => 'me')

      msg.from.should == 'me'
      msg.from_name.should == 'me'
      msg.text.should == ''
    end

    it "can be constructed from another message" do
      msg  = Message.new(:from => 'me')
      msg2 = Message.from_message(msg, :to => 'you')

      msg2.from.should == 'me'
      msg2.to.should == 'you'
    end

    it "has a text attribute" do
      msg = Message.new(:from => 'x', :from_name => 'x', :text => 'text')

      msg.text.should == 'text'
    end

    it "has accessible to and chat attributes" do
      msg = Message.new(:from => 'x', :from_name => 'x', :to => 'to', :chat => 'chat')

      msg.to.should == 'to'
      msg.chat.should == 'chat'

      msg.to = 'other to'
      msg.chat = 'other chat'

      msg.to.should == 'other to'
      msg.chat.should == 'other chat'
    end

    it "knows me case insensitively" do
      Config.stub(:me).and_return('me')

      msg = Message.new(:from => 'x', :from_name => 'x', :to => 'me')
      msg.to_me?.should be_true

      msg.to = 'Me'
      msg.to_me?.should be_true

      msg.to = 'you'
      msg.to_me?.should be_false
    end

    it "should dispatch through responders and watchers" do
      responder = Plugin.respond_to(/a match/) { self }
      watcher   = Plugin.watch_for(/a match/)  { self }

      msg = Message.new(:from => 'x', :text => 'a match')

      msg.stub(:to_me?).and_return(true)
      msg.dispatch.should == responder

      msg.stub(:to_me?).and_return(false)
      msg.dispatch.should == watcher

      msg = Message.from_message(msg, :text => 'no match')

      msg.dispatch.should be_nil
    end
  end
end
