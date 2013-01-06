require 'spec_helper'

module Basil
  describe Config do
    before do
      Config.invalidate

      @conf = { 'key_foo' => 'foo',
                'key_bar' => 'bar',
                'server_type' => :cli }

      File.stub(:read).and_return(@conf.to_yaml)
    end

    it "has accessors from the config file" do
      Config.key_foo.should == 'foo'
    end

    it "uses server_type to instantiate the right server" do
      Config.server.should be_a(Cli)
    end

    it "can hold a debug setting" do
      Config.debug?.should be_false

      Config.debug = true

      Config.debug?.should be_true
    end

    it "can be hidden" do
      Config.hide do
        Config.key_foo.should be_nil
      end
    end
  end
end
