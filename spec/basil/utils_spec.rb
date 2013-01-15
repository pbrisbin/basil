require 'spec_helper'

module Basil
  describe Utils do
    let(:plugin) { double.tap { |p| p.extend(Utils) } }

    it "provides current chat's history" do
      options = { :foo => 'foo', :bar => 'bar' }
      ChatHistory.should_receive(:get_messages).with('chat', options)

      plugin.stub(:chat).and_return('chat')
      plugin.chat_history(options)
    end

    it "purges current chat's history" do
      ChatHistory.should_receive(:clear).with('chat')

      plugin.stub(:chat).and_return('chat')
      plugin.purge_history!
    end

    it "provides parse_http" do
      resp = double("resp", :body => 'a body')
      plugin.should_receive(:get_http).with('args').and_return(resp)

      result = plugin.parse_http('args') { |b| b }
      result.should == 'a body'
    end
  end
end
