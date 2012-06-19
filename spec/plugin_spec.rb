require 'spec_helper'

module Basil
  describe Plugin do
    before do
      Plugin.responders.clear
      Plugin.watchers.clear
      Plugin.email_checkers.clear
    end

    it "can be registered as one of three types" do
      p_responder = Plugin.respond_to(/regex/)  { }
      p_watcher   = Plugin.watch_for(/regex/)   { }
      p_checker   = Plugin.check_email(/regex/) { }

      Plugin.responders.should     == [p_responder]
      Plugin.watchers.should       == [p_watcher]
      Plugin.email_checkers.should == [p_checker]
    end
  end

  describe Plugin, '#triggered?' do
    before do
      Plugin.responders.clear

      @p = Plugin.respond_to(/a (match)/) do
        return { :msg        => @msg,
                 :match_data => @match_data }
      end

      @msg = double('message', :text => 'this is a match')
    end

    it "sets @msg" do
      msg = @p.triggered?(@msg)[:msg]

      msg.should == @msg
    end

    it "sets @match_data" do
      match_data = @p.triggered?(@msg)[:match_data]

      match_data[0].should == 'a match'
      match_data[1].should == 'match'
    end

    it "skips non matches" do
      msg = double("message", :text => 'no match')

      @p.triggered?(msg).should be_nil
    end
  end

  describe Plugin, '#email_triggered?' do
    before do
      Plugin.email_checkers.clear

      @p = Plugin.check_email(/a (match)/) do
        return { :msg        => @msg,
                 :match_data => @match_data }
      end

      @mail = { 'Subject' => 'this is a match',
                'From'    => 'from' }

      @mail.stub(:body).and_return('the email body')
    end

    it "sets @msg from the mail" do
      msg = @p.email_triggered?(@mail)[:msg]

      msg.to.should        == Config.me
      msg.from.should      == 'from'
      msg.from_name.should == 'from'
      msg.text.should      == 'the email body'
    end

    it "sets @match_data email" do
      match_data = @p.email_triggered?(@mail)[:match_data]

      match_data[0].should == 'a match'
      match_data[1].should == 'match'
    end

    it "skips non matches" do
      mail = { 'Subject' => 'no match' }
      mail.stub(:body)

      @p.email_triggered?(mail).should be_nil
    end
  end
end
