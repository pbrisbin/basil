require 'spec_helper'

module Basil
  describe SkypeMessage do
    let(:skype) { double('skype') }

    before do
      skype.stub(:get).and_return('some property') # unused default
      skype.stub(:get).with("CHATMESSAGE 1 CHATNAME").and_return('chatname')
      skype.stub(:get).with("CHATMESSAGE 1 FROM_HANDLE").and_return('jsmith')
      skype.stub(:get).with("CHATMESSAGE 1 FROM_DISPNAME").and_return('Jim Smith')
    end

    def accept(text)
      skype.stub(:get).with("CHATMESSAGE 1 BODY").and_return(text)

      SkypeMessage.new(skype, 1)
    end

    it "gets skype info via the API" do
      msg = accept('some text')

      msg.chatname.should      == 'chatname'
      msg.from_handle.should   == 'jsmith'
      msg.from_dispname.should == 'Jim Smith'
      msg.body.should          == 'some text'
    end

    context "when in private chat" do
      before do
        skype.stub(:get).with("CHAT chatname MEMBERS").and_return('one two')
      end

      it "sets private_chat to true" do
        accept('xyz').private_chat?.should be_true
      end

      it "sees everything as to me" do
        ['plain message', 'to, someone else'].each do |text|
          msg = accept(text)

          msg.to.should == Config.me
          msg.text.should == text
        end
      end

      it "strips bang and bracket shortcuts" do
        accept('!command').text.should == 'command'
        accept('! command').text.should == 'command'
        accept('> code').text.should == 'eval code'
        accept('>  code').text.should == 'eval code'
      end
    end

    context "when not in private chat" do
      before do
        skype.stub(:get).with("CHAT chatname MEMBERS").and_return('one two three')
      end

      it "sets private_chat to false" do
        accept('xyz').private_chat?.should be_false
      end

      it "parses BODY correctly for typical TO and TEXT components" do
        examples = {
          '@someone  some text' => ['someone', 'some text'],
          '@someone, some text' => ['someone', 'some text'],
          '@someone: some text' => ['someone', 'some text'],
          '@someone; some text' => ['someone', 'some text'],
          'someone,  some text' => ['someone', 'some text'],
          'someone:  some text' => ['someone', 'some text'],
          'someone;  some text' => ['someone', 'some text']
        }

        examples.each do |k,v|
          msg = accept(k)

          [msg.to, msg.text].should == v
        end
      end

      it "sees bang commands as to me" do
        ['!some text', '!  some text'].each do |text|
          msg = accept(text)

          msg.to.should == Config.me
          msg.text.should == 'some text'
        end
      end

      it "interprets > as evaluation" do
        msg = accept('> some code')

        msg.to.should == Config.me
        msg.text.should == 'eval some code'
      end

      it "handles plain messages" do
        msg = accept('some text')

        msg.to.should be_nil
        msg.text.should == 'some text'
      end
    end
  end
end
