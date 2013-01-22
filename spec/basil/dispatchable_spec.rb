require 'spec_helper'

module Basil
  class DispatchableDouble
    include Dispatchable

    def each_plugin(&block)
    end

    def match?(plugin)
    end

    def to_message
      Message.new(:from => 'x')
    end
  end

  describe DispatchableDouble do
    it_behaves_like "a Dispatchable"
  end

  describe Dispatchable do
    subject { DispatchableDouble.new }

    before { ChatHistory.stub(:store) }

    it "should store the object in chat history" do
      ChatHistory.should_receive(:store).with(subject)

      subject.dispatch
    end

    it "should handle errors during dispatching" do
      subject.stub(:each_plugin).and_raise

      expect { subject.dispatch }.to_not raise_error
    end

    context "with registered plugins" do
      let(:plugin1) { double('Plugin 1') }
      let(:plugin2) { double('Plugin 2') }
      let(:plugin3) { double('Plugin 3') }

      before do
        subject.stub(:each_plugin).and_yield(plugin1)
                                  .and_yield(plugin2)
                                  .and_yield(plugin3)
      end

      it "should execute each plugin on itself" do
        plugin1.should_receive(:execute_on).with(subject)
        plugin2.should_receive(:execute_on).with(subject)
        plugin3.should_receive(:execute_on).with(subject)

        subject.dispatch
      end

      it "should handle errors during execution" do
        plugin1.should_receive(:execute_on).with(subject)
        plugin2.should_receive(:execute_on).with(subject).and_raise
        plugin3.should_receive(:execute_on).with(subject)

        expect { subject.dispatch }.to_not raise_error
      end
    end

  end
end
