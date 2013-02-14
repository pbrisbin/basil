require 'spec_helper'

module Basil
  describe Worker do
    let(:pid)   { 123 }
    let(:timer) { double("Timer", :alive? => false) }

    before do
      Timer.stub(:new).and_return(timer)
      Process.stub(:fork).and_yield.and_return(pid)
      Process.stub(:wait) { system("true") }
    end

    it "should fork and set pid" do
      Process.should_receive(:fork).and_yield.and_return(pid)

      w = Worker.new { true }
      w.pid.should == pid
    end

    it "should monitor the process and kill if needed" do
      Worker.any_instance.should_receive(:system).with("kill -9 #{pid}")

      Timer.should_receive(:new).and_yield.and_return(timer)

      Worker.new { true }
    end

    it "should exit the monitoring thread process is OK" do
      timer.stub(:alive?).and_return(true)
      timer.should_receive(:exit)

      Worker.new { true }
    end

    it "should wait and set exit status" do
      Process.should_receive(:wait).with(pid) { system("false") }

      w = Worker.new { true }
      w.exitstatus.should == 1
    end
  end
end
