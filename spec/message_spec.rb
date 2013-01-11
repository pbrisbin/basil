require 'spec_helper'
require 'timecop'

module Basil
  describe 'Message as dispatchable' do
    subject { Message.new(:from => 'x') }

    it_behaves_like "a Dispatchable"
  end

  describe 'Message construction' do
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
  end

  describe 'Message attributes' do
    it "has a text attribute" do
      msg = Message.new(:from => 'x', :text => 'text')

      msg.text.should == 'text'
    end

    it "has accessible to and chat attributes" do
      msg = Message.new(:from => 'x', :to => 'to', :chat => 'chat')

      msg.to.should == 'to'
      msg.chat.should == 'chat'

      msg.to = 'other to'
      msg.chat = 'other chat'

      msg.to.should == 'other to'
      msg.chat.should == 'other chat'
    end

    it "sets a time attribute when created" do
      Timecop.freeze do
        msg = Message.new(:from => 'me')
        msg.time.should == Time.now
      end
    end
  end

  describe 'Message#to_me?' do
    it "is a case insensitive match" do
      Config.stub(:me).and_return('me')

      msg = Message.new(:from => 'x', :to => 'me')
      msg.to_me?.should be_true

      msg.to = 'Me'
      msg.to_me?.should be_true

      msg.to = 'you'
      msg.to_me?.should be_false
    end
  end

  describe 'Message sending' do
    it "can say things"
    it "can reply to itself"
    it "can forward itself"
  end
end
