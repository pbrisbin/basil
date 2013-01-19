require 'spec_helper'

module Basil
  describe Lock do
    subject { described_class }

    before do
      Config.stub(:lock_file).and_return('/tmp/basil_test.lock')
    end

    after do
      if File.exists?(Config.lock_file)
        File.unlink(Config.lock_file)
      end
    end

    it "should write and cleanup a lock file" do
      expect {
        Lock.guard do
          # ensures the file's created
          raise unless File.exists?(Config.lock_file)
        end
      }.to_not raise_error

      File.exists?(Config.lock_file).should be_false
    end

    it "should error and leave it if a lock file exists" do
      File.open(Config.lock_file, 'w') { }

      expect { Lock.guard { } }.to raise_error

      File.exists?(Config.lock_file).should be_true
    end

  end
end
