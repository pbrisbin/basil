require 'spec_helper'

module Basil
  describe Message do
    it "can be constructed with only from/from_name" do
      msg = Message.new(:from => 'me', :from_name => 'Me')

      msg.from.should == 'me'
      msg.from_name.should == 'Me'
      msg.text.should == ''
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
  end
end
