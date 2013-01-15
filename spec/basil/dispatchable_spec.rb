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
      double('message', :chat => nil, :server= => true)
    end

    let(:server) { double('server') }
    let(:plugin) { double('plugin') }

    before do
      subject.stub(:to_message).and_return(message)
    end

    it "should store in chat history if chat is known" do
      message.stub(:chat).and_return(:not_nil)

      ChatHistory.should_receive(:store_message).with(message)

      subject.dispatch(server)
    end

    it "should not store in chat if chat is not known" do
      message.stub(:chat).and_return(nil)

      ChatHistory.should_not_receive(:store_message)

      subject.dispatch(server)
    end

    it "should assign the server to message pre-dispatch" do
      message.should_receive(:server=).with(server)

      subject.dispatch(server)
    end

    it "should call match for each plugin" do
      subject.stub(:each_plugin).and_yield(plugin)

      subject.should_receive(:match?).with(plugin)

      subject.dispatch(server)
    end

    it "should set context and execute on matches" do
      subject.stub(:each_plugin).and_yield(plugin)
      subject.stub(:match?).and_return('match data')

      plugin.should_receive(:set_context).with(message, 'match data')
      plugin.should_receive(:execute)

      subject.dispatch(server)
    end

    it "should not execute on non-matches" do
      subject.stub(:each_plugin).and_yield(plugin)
      subject.stub(:match?).and_return(nil)

      plugin.should_not_receive(:set_context)
      plugin.should_not_receive(:execute)

      subject.dispatch(server)
    end

  end
end
