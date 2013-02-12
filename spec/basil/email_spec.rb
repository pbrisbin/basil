require 'spec_helper'

module Basil
  describe Email do
    it "should fork the worker in a thread and store the thread" do
      worker = double("worker")
      worker.should_receive(:run)
      Email::Worker.stub(:new).and_return(worker)

      thread = double("thread")
      Thread.should_receive(:new).and_yield.and_return(thread)

      Email.should_receive(:fork).and_yield

      Email.check(true) # once

      Email.thread.should == thread
    end
  end
end
