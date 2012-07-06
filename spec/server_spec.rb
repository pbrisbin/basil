require 'spec_helper'

module Basil
  describe Server, 'dispatch_message' do
    before do
      @server = Server.new
      @server.stub(:server_command?).and_return(nil)

      ChatHistory.stub(:store_message)
      Dispatch.stub(:extended) { |msg| msg }
      Dispatch.stub(:simple)   { |msg| msg }

      @msg = Message.new('to', 'from', 'from_name', 'text', 'chat')
    end

    it "should store in chat history" do
      ChatHistory.should_receive(:store_message).once.with(@msg)

      @server.dispatch_message(@msg).should == @msg
    end

    it "should look for server commands" do
      @server.should_receive(:server_command?).once.with(@msg)

      @server.dispatch_message(@msg).should == @msg
    end

    it "should respect extended dispatcher_type" do
      Config.stub(:dispatcher_type).and_return(:extended)

      Dispatch.should_receive(:extended)
      Dispatch.should_not_receive(:simple)

      @server.dispatch_message(@msg)
    end

    it "should respect simple dispatcher_type" do
      Config.stub(:dispatcher_type).and_return(:simple)

      Dispatch.should_receive(:simple)
      Dispatch.should_not_receive(:extended)

      @server.dispatch_message(@msg)
    end
  end

  describe Server, 'commands' do
    before do
      class MyServer < Server
        has_command(:command) { |*args| args }
      end

      @server = MyServer.new
    end

    it "stores server commands" do
      @server.class.server_commands.length.should == 1
    end

    it "calls commands with shell split arguments" do
      msg = stub(:to_me? => true,
                 :text   => "/command arg1 'arg two'")

      @server.server_command?(msg).should == ['arg1', 'arg two']
    end

    it "passes through non-commands" do
      msg = stub(:to_me? => true,
                 :text   => "just a message")

      @server.server_command?(msg).should be_nil

      msg = stub(:to_me? => true,
                 :text   => "/nonexistent")

      @server.server_command?(msg).should be_nil
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
end
