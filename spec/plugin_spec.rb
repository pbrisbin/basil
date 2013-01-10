require 'spec_helper'

module Basil
  describe Plugin, 'construction' do
    before do
      Plugin.responders.clear
      Plugin.watchers.clear
      Plugin.email_checkers.clear

      @responder = Plugin.respond_to(/regex/)   { self }
      @watcher   = Plugin.watch_for(/regex/)    { self }
      @checker   = Plugin.check_email("string") { self }
    end

    it "registers correctly" do
      Plugin.responders.should     == [@responder]
      Plugin.watchers.should       == [@watcher]
      Plugin.email_checkers.should == [@checker]
    end

    it "assigns and execute block" do
      @responder.execute.should == @responder
      @watcher.execute.should   == @watcher
      @checker.execute.should   == @checker
    end

    it "handles regex or string" do
      @responder.regex.should == /regex/
      @watcher.regex.should   == /regex/
      @checker.regex.should   == /^string$/
    end

    it "assigns the correct type" do
      @responder.type.should == :responder
      @watcher.type.should   == :watcher
      @checker.type.should   == :email_checker
    end

    it "has an accessible description" do
      @responder.description.should be_nil
      @responder.description = 'A description'
      @responder.description.should == 'A description'
    end
  end

  describe 'Plugin#set_context' do
    it "sets the correct instance variables" do
      p = Plugin.respond_to(/x/) { }
      p.set_context('msg', 'match_data')

      p.instance_variable_get(:@msg).should == 'msg'
      p.instance_variable_get(:@match_data).should == 'match_data'
    end
  end
end
