require 'spec_helper'

module Basil
  describe Server do
    it "loads plugins and runs the main loop" do
      server = Class.new(Server).new

      Plugin.should_receive(:load!)

      msg = mock
      msg.should_receive(:dispatch).with(server)

      server.should_receive(:main_loop).and_yield('some', 'args')
      server.should_receive(:accept_message).with('some' ,'args').and_return(msg)

      server.start
    end
  end

  describe Server, 'with locked start' do
    before do
      Config.stub(:lock_file).and_return('/tmp/basil_test.lock')
    end

    subject do
      Class.new(Server) do
        def start
          # to ensure we created one
          raise unless File.exists?(Config.lock_file)
        end

        lock_start
      end.new
    end

    after do
      if File.exists?(Config.lock_file)
        File.unlink(Config.lock_file)
      end
    end

    it "should write and cleanup a lock file" do
      lambda { subject.start }.should_not raise_error

      File.exists?(Config.lock_file).should be_false
    end

    it "should error and leave it if a lock file exists" do
      File.write(Config.lock_file, '');

      lambda { subject.start }.should raise_error

      File.exists?(Config.lock_file).should be_true
    end
  end
end
