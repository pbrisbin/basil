require 'spec_helper'

module Basil
  describe Server do
    subject { Class.new(Server).new }

    it "loads plugins and runs the main loop" do
      Plugin.should_receive(:load!)

      msg = mock
      msg.should_receive(:dispatch)

      subject.should_receive(:main_loop).and_yield('some', 'args')
      subject.should_receive(:accept_message).with('some' ,'args').and_return(msg)

      subject.start
    end

    it "uses Lock.guard when start is locked" do
      subject.stub(:main_loop)
      subject.stub(:accept_message)

      subject.class.lock_start

      Lock.should_receive(:guard).and_yield

      subject.start
    end
  end
end
