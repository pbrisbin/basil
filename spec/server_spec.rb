require 'spec_helper'

module Basil
  describe Server do
    it "loads plugins and runs the main loop" do
      server = Class.new(Server).new

      Plugin.should_receive(:load!)
      Email.should_not_receive(:check)

      server.should_receive(:main_loop).and_yield('some', 'args')
      server.should_receive(:build_message).with('some' ,'args').and_return(nil)

      server.start
    end

    it "checks email for servers that support it" do
      server = Class.new(Server).new

      Plugin.stub(:load!)
      server.stub(:main_loop)

      Email.should_receive(:check)
      server.stub(:broadcast_message)

      server.start
    end

    it "stores messages in history and dispatches them" do
      server = Class.new(Server).new

      Plugin.stub(:load!)
      server.stub(:main_loop).and_yield
      server.stub(:build_message).and_return('a message')

      ChatHistory.should_receive(:store_message).with('a message')
      Dispatch.should_receive(:process).with('a message').and_return('a reply')

      # we rely on the fact that our test double returns the result of
      # dispatching from the start call.
      server.start.should == 'a reply'
    end
  end

  describe Server, 'with locked start' do
    before do
      Config.stub(:lock_file).and_return('/tmp/basil_test.lock')

      class MyServer < Server
        def start
          # to ensure we created one
          raise unless File.exists?(Config.lock_file)
        end

        lock_start
      end

      @server = MyServer.new
    end

    after do
      if File.exists?(Config.lock_file)
        File.unlink(Config.lock_file)
      end
    end

    it "should write and cleanup a lock file" do
      lambda { @server.start }.should_not raise_error

      File.exists?(Config.lock_file).should be_false
    end

    it "should error and leave it if a lock file exists" do
      File.write(Config.lock_file, '');

      lambda { @server.start }.should raise_error

      File.exists?(Config.lock_file).should be_true
    end
  end
end
