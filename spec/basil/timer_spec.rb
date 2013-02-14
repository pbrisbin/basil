require 'spec_helper'

module Basil
  describe Timer do
    let(:thread) { double("Thread") }

    before do
      Thread.stub(:new).and_yield.and_return(thread)
    end

    it "should spawn a new thread" do
      Thread.should_receive(:new).and_yield

      sentinal = nil

      Timer.new(:once => true) { sentinal = true }

      sentinal.should be_true
    end

    it "should delegate all calls to the thread" do
      thread.should_receive(:any_method)

      timer = Timer.new(:once => true)
      timer.any_method
    end
  end
end
