require 'spec_helper'
require 'fakeweb'

module Basil
  describe 'HTTP.get' do
    before do
      FakeWeb.allow_net_connect = false
    end

    after do
      FakeWeb.clean_registry
    end

    it "accepts a simple url" do
      FakeWeb.register_uri(:get, "http://x.com", :body => 'A body')

      HTTP.get('http://x.com').body.should == 'A body'
    end

    it "accepts an options hash for HTTPS and basic auth" do
      FakeWeb.register_uri(:get, 'https://u:p@x.com/y', :body => 'A body')

      HTTP.get('host' => 'x.com', 'port' => 443, 'path' => '/y',
               'user' => 'u', 'password' => 'p').body.should == 'A body'
    end
  end
end
