require 'spec_helper'

module Basil
  describe Plugin do
    subject { described_class }

    describe 'load' do
      before do
        plugin_files = %w( d.rb x.rb a.rb )

        Dir.stub(:exists?).and_return(true)
        Dir.stub(:glob).and_return(plugin_files)
      end

      it "loads plugins alphabetically" do
        subject.should_receive(:load).with('a.rb').ordered
        subject.should_receive(:load).with('d.rb').ordered
        subject.should_receive(:load).with('x.rb').ordered

        subject.load!
      end

      it "rescues any errors" do
        subject.stub(:load).and_raise

        lambda { subject.load! }.should_not raise_error
      end
    end

    context 'registration' do
      let(:responder) { subject.respond_to(/regex/)   { self } }
      let(:watcher)   { subject.watch_for(/regex/)    { self } }
      let(:checker)   { subject.check_email("string") { self } }

      before do
        subject.responders.clear
        subject.watchers.clear
        subject.email_checkers.clear
      end

      it "registers correctly" do
        subject.responders.should     == [responder]
        subject.watchers.should       == [watcher]
        subject.email_checkers.should == [checker]
      end

      it "assigns an execute block" do
        responder.execute.should == responder
        watcher.execute.should   == watcher
        checker.execute.should   == checker
      end

      it "handles regex or string" do
        responder.regex.should == /regex/
        checker.regex.should   == /^string$/
      end

      it "has an accessible description" do
        responder.description.should be_nil
        responder.description = 'A description'
        responder.description.should == 'A description'
      end
    end

    describe '#set_context' do
      let(:instance) { subject.respond_to(/x/) { } }

      it "sets the correct instance variables" do
        instance.set_context('msg', 'match_data')

        instance.instance_variable_get(:@msg).should == 'msg'
        instance.instance_variable_get(:@match_data).should == 'match_data'
      end
    end
  end
end