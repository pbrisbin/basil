require 'spec_helper'

module Basil
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
