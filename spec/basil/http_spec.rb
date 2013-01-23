require 'spec_helper'
require 'fakeweb'

module Basil
  describe HTTP, 'get' do
    subject { described_class }

    before { FakeWeb.allow_net_connect = false }

    after { FakeWeb.clean_registry }

    it "accepts a simple url" do
      FakeWeb.register_uri(:get, "http://x.com", :body => 'A body')

      subject.get('http://x.com').body.should == 'A body'
    end

    it "accepts an options hash for HTTPS and basic auth" do
      FakeWeb.register_uri(:get, 'https://u:p@x.com/y', :body => 'A body')

      subject.get('host' => 'x.com', 'port' => 443, 'path' => '/y',
                  'user' => 'u', 'password' => 'p').body.should == 'A body'
    end

    it "warns on non-200 requests" do
      FakeWeb.register_uri(:get, "http://notfound.com", :body => 'Not found',
                                                        :status => ['404', 'Not Found'])

      # some test coupling here
      Loggers['http'].should_receive(:warn).with('Non-200 HTTP Response')
      Loggers['http'].should_receive(:warn).with(kind_of(Net::HTTPNotFound))

      subject.get('http://notfound.com').body.should == 'Not found'
    end
  end
end
