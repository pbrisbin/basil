require 'spec_helper'

module Basil
  describe Skype do
    subject { described_class.new }

    let(:skype) { double }

    before { subject.stub(:skype).and_return(skype) }

    it_behaves_like "a Server"

    it "listens to skype in its main loop " do
      skype.should_receive(:on_chatmessage_received)
      skype.should_receive(:connect)
      skype.should_receive(:run)

      subject.main_loop
    end

    it "accepts a message via skype API" do
      skype.should_receive(:get).with("CHATMESSAGE 1 BODY").and_return('text')
      skype.should_receive(:get).with("CHATMESSAGE 1 CHATNAME").and_return('chat')
      skype.should_receive(:get).with("CHATMESSAGE 1 FROM_HANDLE").and_return('from')
      skype.should_receive(:get).with("CHATMESSAGE 1 FROM_DISPNAME").and_return('from name')
      skype.should_receive(:get).with("CHAT chat MEMBERS").and_return('me you him')

      msg = subject.accept_message('1')

      msg.to.should be_nil
      msg.from.should == 'from'
      msg.from_name.should == 'from name'
      msg.text.should == 'text'
      msg.chat.should == 'chat'
    end

    it "knows when messages are to him in group chat" do
      skype.stub(:get).and_return('a property')

      skype.stub(:get).with("CHATMESSAGE 1 CHATNAME").and_return('chat')
      skype.stub(:get).with("CHAT chat MEMBERS").and_return('me you him')

      Config.stub(:me).and_return('me')

      to_me = ['> me ...', '@me ...', '!...', 'me, ...', 'me: ...']

      not_to_me = ['@variable', 'some text', 'you, ...']

      to_me.each do |text|
        skype.stub(:get).with("CHATMESSAGE 1 BODY").and_return(text)
        msg = subject.accept_message('1')
        msg.to_me?.should be_true
      end

      not_to_me.each do |text|
        skype.stub(:get).with("CHATMESSAGE 1 BODY").and_return(text)
        msg = subject.accept_message('1')
        msg.to_me?.should be_false
      end
    end

    it "sees all messages as to him in private chat" do
      # catch-all for properties we don't care about
      skype.stub(:get).and_return('a property')

      skype.stub(:get).with("CHATMESSAGE 1 CHATNAME").and_return('chat')
      skype.stub(:get).with("CHAT chat MEMBERS").and_return('me you')

      ['any thing', 'at all'].each do |text|
        skype.stub(:get).with("CHATMESSAGE 1 BODY").and_return(text)
        msg = subject.accept_message('1')
        msg.to_me?.should be_true
      end
    end

    it "sends a message via skype API" do
      skype.should_receive(:message_chat).with('chat', 'john, text')

      subject.send_message(
        Message.new(
          :to   => 'john smith',
          :from => 'x',
          :text => 'text',
          :chat => 'chat'
      ))
    end
  end
end
