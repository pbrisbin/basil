require 'spec_helper'

module Basil
  describe Utils do
    before do
      class MyPlugin
        include Utils

        attr_accessor :msg

        def logger
          Loggers['global']
        end
      end

      @plugin = MyPlugin.new
      @plugin.msg = Message.new(:to => 'to', :from => 'from', :from_name => 'from_name', :text =>'text', :chat => 'chat')
    end

    it "provides chat history" do
      options = { :foo => 'foo', :bar => 'bar' }

      ChatHistory.should_receive(:get_messages).with('chat', options)

      @plugin.chat_history(options)
    end

    it "can purge chat history" do
      ChatHistory.should_receive(:clear).with('chat')

      @plugin.purge_history!
    end

    it "provides says" do
      reply = @plugin.says "something"

      reply.to.should be_nil
      reply.text.should == "something"
      reply.chat.should == "chat"

      reply = @plugin.says "something" do |out|
        out << "line one"
        out << "line two"
      end

      reply.text.should == "something\nline one\nline two"
    end

    it "provides replies" do
      reply = @plugin.replies "something"

      reply.to.should   == "from_name"
      reply.text.should == "something"
      reply.chat.should == "chat"

      reply = @plugin.replies "something" do |out|
        out << "line one"
        out << "line two"
      end

      reply.text.should == "something\nline one\nline two"
    end

    it "provides forwards_to" do
      @plugin.forwards_to('new_to').to.should == 'new_to'
    end

    it "provides set_chat" do
      @plugin.set_chat('new_chat')

      @plugin.msg.chat.should == 'new_chat'
    end

    it "provides escape" do
      # no need to test CGI::escape all that thoroughly...
      @plugin.escape('foo bar').should == 'foo+bar'
    end


    it "provides parse_http" do
      resp = double("resp", :body => 'a body')
      @plugin.should_receive(:get_http).with('args').and_return(resp)

      result = @plugin.parse_http('args') { |b| b }
      result.should == 'a body'
    end

    # TODO: is this test too intrusive?
    it "provides some useful parsers" do
      require 'json'
      require 'faster_xml_simple'
      require 'nokogiri'

      JSON.should_receive(:parse ).with('body').and_return('parsed json')
      FasterXmlSimple.should_receive(:xml_in).with('body').and_return('parsed xml')
      Nokogiri::HTML.should_receive(:parse ).with('body').and_return('parsed html')

      @plugin.stub(:parse_http).and_yield('body')

      @plugin.get_json.should == 'parsed json'
      @plugin.get_xml.should == 'parsed xml'
      @plugin.get_html.should == 'parsed html'
    end
  end
end
