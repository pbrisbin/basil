require 'spec_helper'

module Basil
  describe Email::Mail do
    it "parses from simple emails" do
      content = [
        'Date: A date',
        'Subject: A subject',
        'To: A to address',
        'From: A from address',
        'Foo: A header with',
        '  continuation',
        '',
        'Some multi-',
        'line body'
      ].join("\r\n") # CRLF

      mail = Email::Mail.parse(content)

      mail['Date'].should    == 'A date'
      mail['Subject'].should == 'A subject'
      mail['To'].should      == 'A to address'
      mail['From'].should    == 'A from address'
      mail['Foo'].should     == 'A header with continuation'
      mail.body.should       == "Some multi-\nline body"
    end
  end

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

      reply = double('reply', :pretty => "a reply")
      Dispatch.should_receive(:email).with('a mail').and_return(reply)

      @server.should_receive(:broadcast_message).with(reply)

      Email.check
    end
  end
end
