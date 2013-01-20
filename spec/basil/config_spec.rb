require 'spec_helper'

module Basil
  describe Config do
    # Use a dup so other tests aren't affected
    subject { Config.dup }

    it "should have some defaults" do
      subject.me.should == 'basil'
      subject.server_class.should == Skype
    end

    it "should have overridable defaults" do
      subject.me = 'not basil'
      subject.me.should == 'not basil'

      subject.server = :a_server
      subject.server.should == :a_server
    end

    it "should lazily instantiate server_class" do
      subject.server_class = Cli

      subject.server = nil
      subject.server.should be_a(Cli)
    end

    it "should load extras" do
      # ensure the exists? check passes
      subject.stub(:config_file).and_return(__FILE__)

      # but don't actually load from it
      File.stub(:read).and_return(
        {'foo' => :foo, 'bar' => :bar}.to_yaml
      )

      subject.foo.should be_nil
      subject.bar.should be_nil

      subject.load!

      subject.foo.should == :foo
      subject.bar.should == :bar
    end

    it "can be hidden" do
      subject.extras = :not_nil

      subject.hide do
        subject.extras.should == {}
      end

      subject.extras.should == :not_nil
    end
  end
end
