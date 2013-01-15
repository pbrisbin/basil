require 'spec_helper'

module Basil
  describe Message do
    context 'constructors' do
      subject { described_class }

      describe '#initialize' do
        it "should raise on invalid arguments" do
          lambda { subject.new(:to => 'you') }.should raise_error(ArgumentError)
        end

        it "works with only from specified" do
          msg = subject.new(:from => 'x')

          msg.from.should      == 'x'
          msg.from_name.should == 'x'
          msg.text.should      == ''

          msg.to.should be_nil
          msg.chat.should be_nil
        end
      end

      describe 'from_message' do
        it "constructs a new message from the first" do
          msg = subject.from_message(described_class.new(:from => 'me'), :to => 'you')

          msg.from.should == 'me'
          msg.to.should   == 'you'
        end
      end
    end

    describe 'an instance' do
      subject { described_class.new(:from => 'x') }

      it_behaves_like "a Dispatchable"

      it "has accessible to and chat attributes" do
        subject.to = 'other to'
        subject.chat = 'other chat'

        subject.to.should == 'other to'
        subject.chat.should == 'other chat'
      end

      it "sets a time attribute" do
        subject.time.should_not be_nil
      end

      it "provides to_me? case insensitively" do
        Config.stub(:me).and_return('someone')

        subject.to_me?.should be_false

        %w( someone SomeOne SOMEONE ).each do |me|
          subject.to = me
          subject.to_me?.should be_true
        end
      end

      context 'with a server' do
        subject do
          described_class.new(
            :to        => 'to',
            :from      => 'from',
            :from_name => 'from name',
            :text      => 'text',
            :chat      => 'chat'
          )
        end

        let(:server) do
          Struct.new(:sent_messages) do
            def send_message(msg)
              self.sent_messages << "#{msg.to}, #{msg.text}"
            end
          end.new([])
        end

        before do
          subject.server = server
        end

        it "can say things" do
          subject.say "some text"
          subject.say "some other text"

          server.sent_messages.should == [', some text', ', some other text']
        end

        it "can reply to itself" do
          subject.reply "some text"

          server.sent_messages.should == ['from name, some text']
        end

        it "can forward itself" do
          subject.forward('new to')

          server.sent_messages.should == ['new to, text']
        end
      end
    end
  end
end
