require 'spec_helper'

module Basil
  describe Skype do
    let(:skype) { double('skype') }

    before { subject.stub(:skype).and_return(skype) }

    it_behaves_like "a Server"

    it "listens to skype in its main loop " do
      skype.should_receive(:on_chatmessage_received)
      skype.should_receive(:connect)
      skype.should_receive(:run)

      subject.main_loop
    end

    it "builds a Message from the SkypeMessage" do
      skype_message = double('skype_message',
                             :from_handle   => 'from',
                             :from_dispname => 'from_name',
                             :to            => 'to',
                             :chatname      => 'chat',
                             :text          => 'text')

      SkypeMessage.should_receive(:new).with(skype, 1).and_return(skype_message)

      msg = subject.accept_message(1)

      msg.from.should      == 'from'
      msg.from_name.should == 'from_name'
      msg.to.should        == 'to'
      msg.chat.should      == 'chat'
      msg.text.should      == 'text'
    end

    it "sends a formatted message via skype API" do
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
