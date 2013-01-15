require 'spec_helper'

module Basil
  describe Email do
    subject { described_class }

    let(:imap) { double('imap') }

    let(:attrs) do
      double('attrs', :attr => {'RFC822' => 'message body'})
    end

    before do
      Net::IMAP.stub(:new).and_return(imap)

      Thread.stub(:new).and_yield # so we don't fork
      subject.stub(:poll_email?).and_return(false) # so we don't loop
    end

    it "should check for mail" do
      # before
      imap.should_receive(:login).ordered
      imap.should_receive(:select).ordered

      # the search
      imap.should_receive(:search).ordered.and_return(['message_id'])
      imap.should_receive(:fetch).ordered.with('message_id', 'RFC822').and_return([attrs])

      # the handling
      mail = mock
      mail.should_receive(:dispatch).with(Config.server)

      Email::Mail.should_receive(:parse).with('message body').and_return(mail)

      # after
      imap.should_receive(:logout).ordered
      imap.should_receive(:disconnect).ordered

      subject.check
    end
  end
end
