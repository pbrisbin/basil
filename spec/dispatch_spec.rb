require 'spec_helper'

module Basil
  describe Dispatch, 'simple' do
    it "simply delegates to the message" do
      msg = double('msg')
      msg.should_receive(:dispatch)

      Dispatch.simple(msg)
    end
  end

  describe Dispatch, 'extended' do
    before do
      Plugin.responders.clear

      Plugin.respond_to(/echo (.*)/) do
        says @match_data[1]
      end
    end

    def msg(text)
      Message.new(:to => Config.me, :from => 'from', :from_name => 'from_name', :text => text, :chat => 'chat')
    end

    it "dispatches normally" do
      Dispatch.extended(msg("echo foo")).text.should == "foo"
    end

    it "handles substitution" do
      Dispatch.extended(msg("echo foo $(echo bar) $(echo baz $(echo bat))")).text.should == "foo bar baz bat"
    end

    it "handles pipe lines" do
      Dispatch.extended(msg("echo foo | echo bar | echo")).text.should == "bar foo"
    end

    it "handles substitution in a pipe line" do
      Dispatch.extended(msg("echo $(echo foo) | echo bar")).text.should == "bar foo"
    end

    it "handles pipe lines in a substitution" do
      Dispatch.extended(msg("echo $(echo foo | echo bar) baz")).text.should == "bar foo baz"
    end

    it "dispatches normally on bad substitution" do
      Dispatch.extended(msg("echo $(bad)")).text.should == "$(bad)"
    end

    it "dispatches normally on bad pipeline" do
      Dispatch.extended(msg("echo foo | bad")).text.should == "foo | bad"
    end
  end
end
