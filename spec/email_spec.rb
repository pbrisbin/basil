require 'spec_helper'

module Basil
  describe Email, 'check' do
    before do
      Thread.stub(:new).and_yield
      Email.stub(:poll_email?).and_return(false)

      @server = double("server")
      @server.stub(:broadcast_message)
      Config.stub(:server).and_return(@server)

      @imap = double("imap", :store => nil)
      Email.stub(:with_imap).and_yield(@imap)
    end

    it "should search imap" do
      @imap.should_receive(:search).and_return([])

      Email.check
    end

    it "should parse and dispatch mails" do
      attrs = double('attrs', :attr => {'RFC822' => 'message body'})

      @imap.should_receive(:search).and_return(['message_id'])
      @imap.should_receive(:fetch).with('message_id', 'RFC822').and_return([attrs])

      Email::Mail.should_receive(:parse).with('message body').and_return('a mail')

      Dispatch.should_receive(:process).with('a mail').and_return('a reply')

      @server.should_receive(:broadcast_message).with('a reply')

      Email.check
    end
  end
end
