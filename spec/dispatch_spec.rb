require 'spec_helper'

module Basil
  describe Dispatch, 'process' do
    before do
      Plugin.responders.clear

      Plugin.respond_to(/echo (.*)/) do
        says @match_data[1]
      end

      Config.stub(:dispatch_type).and_return(:extended)
    end

    def msg(text)
      Message.new(:to => Config.me, :from => 'from', :from_name => 'from_name', :text => text, :chat => 'chat')
    end

    it "dispatches normally" do
      Dispatch.process(msg("echo foo")).text.should == "foo"
    end

    it "handles substitution" do
      Dispatch.process(msg("echo foo $(echo bar) $(echo baz $(echo bat))")).text.should == "foo bar baz bat"
    end

    it "handles pipe lines" do
      Dispatch.process(msg("echo foo | echo bar | echo")).text.should == "bar foo"
    end

    it "handles substitution in a pipe line" do
      Dispatch.process(msg("echo $(echo foo) | echo bar")).text.should == "bar foo"
    end

    it "handles pipe lines in a substitution" do
      Dispatch.process(msg("echo $(echo foo | echo bar) baz")).text.should == "bar foo baz"
    end

    it "dispatches normally on bad substitution" do
      Dispatch.process(msg("echo $(bad)")).text.should == "$(bad)"
    end

    it "dispatches normally on bad pipeline" do
      Dispatch.process(msg("echo foo | bad")).text.should == "foo | bad"
    end

    it "dispatches simply when config is disabled" do
      Config.stub(:dispatch_type).and_return(:not_extended)
      Dispatch.process(msg("echo foo | echo $(echo bar)")).text.should == "foo | echo $(echo bar)"
    end
  end
end
