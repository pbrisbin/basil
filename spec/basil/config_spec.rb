require 'spec_helper'

module Basil
  describe Config do
    it "should have some defaults" do
      Config.me.should == 'basil'
      Config.server_class.should == Skype
    end

    it "should have overridable defaults" do
      Config.me = 'not basil'
      Config.me.should == 'not basil'

      Config.server = :a_server
      Config.server.should == :a_server

      # clean up for other tests
      Config.server = nil
    end

    it "should instantiate server_class" do
      Config.server_class = Cli
      Config.server.should be_a(Cli)
    end

    it "should load extras" do
      # ensure the exists? check passes
      Config.stub(:config_file).and_return(__FILE__)

      # but don't actually load from it
      File.stub(:read).and_return({'foo' => :foo, 'bar' => :bar}.to_yaml)

      Config.load!

      Config.foo.should == :foo
      Config.bar.should == :bar
    end

    it "can be hidden" do
      Config.extras = :not_nil

      Config.hide do
        Config.extras.should == {}
      end

      Config.extras.should == :not_nil
    end
  end
end
