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

    let(:message) do
      double('message', :chat => nil)
    end

    let(:plugin) { double('plugin') }

    before do
      subject.stub(:to_message).and_return(message)
    end

    it "should store the object in chat history" do
      ChatHistory.should_receive(:store).with(subject)

      subject.dispatch
    end

    it "should call match for each plugin" do
      subject.stub(:each_plugin).and_yield(plugin)

      subject.should_receive(:match?).with(plugin)

      subject.dispatch
    end

    it "should set context and execute on matches" do
      subject.stub(:each_plugin).and_yield(plugin)
      subject.stub(:match?).and_return('match data')

      plugin.should_receive(:execute_on).with(subject, 'match data')

      subject.dispatch
    end

    it "should not execute on non-matches" do
      subject.stub(:each_plugin).and_yield(plugin)
      subject.stub(:match?).and_return(nil)

      plugin.should_not_receive(:set_context)
      plugin.should_not_receive(:execute)

      subject.dispatch
    end

  end
end
