require 'spec_helper'

module Basil
  describe Email do
    it "should fork the worker in a thread and store the thread" do
      thread = double("thread")
      Thread.should_receive(:new).and_yield.and_return(thread)

      Process.should_receive(:fork).and_yield.and_return(123)

      worker = double("worker")
      worker.should_receive(:run)
      Email::Worker.stub(:new).and_return(worker)

      Process.should_receive(:wait).with(123)

      Email.check(true) # once

      Email.thread.should == thread
    end
  end
end
