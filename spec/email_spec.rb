require 'spec_helper'

module Basil
  describe Email, 'check' do
    before do
      Thread.stub(:new).and_yield
      Email.stub(:poll_email?).and_return(false)


      @imap = double("imap", :store => nil)
      Email.stub(:with_imap).and_yield(@imap)
    end

    it "should search imap" do
      @imap.should_receive(:search).and_return([])

      Email.check
    end

    it "should parse and dispatch mails" do
      server = double("server")
      Config.stub(:server).and_return(server)

      attrs = double('attrs', :attr => {'RFC822' => 'message body'})

      @imap.should_receive(:search).and_return(['message_id'])
      @imap.should_receive(:fetch).with('message_id', 'RFC822').and_return([attrs])

      mail = mock
      mail.should_receive(:dispatch).with(server)

      Email::Mail.should_receive(:parse).with('message body').and_return(mail)

      Email.check
    end
  end
end
