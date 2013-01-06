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
      @plugin.msg = Message.new('to', 'from', 'from_name', 'text', 'chat')
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

    it "provides get_http simply" do
      require 'net/http' # so we can stub things

      URI.should_receive(:parse).with('a_url').and_return('parsed_url')
      Net::HTTP.should_receive(:get_response).with('parsed_url')

      @plugin.get_http('a_url')
    end

    it "provides get_http with an options hash" do
      require 'net/http' # so we can stub things

      net  = double('net')
      http = double('http')
      req  = double('req')

      Net::HTTP.should_receive(:new).with('host', 'port').and_return(net)
      Net::HTTP::Get.should_receive(:new).with('path').and_return(req)

      net.should_receive(:start).and_yield(http)
      req.should_receive(:basic_auth).with('username', 'password')
      http.should_receive(:request).with(req)

      @plugin.get_http('host' => 'host',
                       'port' => 'port',
                       'path' => 'path',
                       'user' => 'username',
                       'password' => 'password')
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
