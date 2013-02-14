require 'spec_helper'

module Basil
  describe Email do
    let(:checker) do
      double("Checker").tap do |checker|
        Email::Checker.stub(:new).and_return(checker)
      end
    end

    before do
      Timer.stub(:new).and_yield
      Worker.stub(:new).and_yield
    end

    it "should run the email checker" do
      checker.should_receive(:run)

      Email.check
    end

    it "should pass interval to the timer" do
      Config.stub(:email).and_return({'interval' => 5 })

      Timer.should_receive(:new).with(:sleep => 5)

      Email.check
    end

    it "should set thread" do
      thread = double("Timer thread")

      Timer.stub(:new).and_return(thread)

      Email.check

      Email.thread.should == thread
    end
  end
end
