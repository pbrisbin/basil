require 'spec_helper'

module Basil
  describe Daemon do
    subject { described_class }

    let(:server) { double("server").as_null_object }

    before { Config.stub(:server).and_return(server) }

    context "start" do
      context "when in forground" do
        it "starts the server" do
          server.should_receive(:start)
          subject.start(true)
        end
      end

      context "when in background" do
        before do
          Config.stub(:foreground?).and_return(false)

          subject.stub(:puts)
          subject.stub(:fork).and_yield

          File.stub(:open).and_yield(double.as_null_object)

          [STDIN, STDOUT, STDERR].each do |io|
            io.stub(:reopen)
            io.stub(:sync)
          end
        end

        it "writes a pid file" do
          Process.stub(:pid).and_return(123)

          fh = double("file handle")
          fh.should_receive(:puts).with("123")

          File.should_receive(:open).with(Config.pid_file, 'w').and_yield(fh)

          subject.start
        end

        it "redirects IO to the configured log file" do
          STDIN.should_receive(:reopen).with("/dev/null")
          STDOUT.should_receive(:reopen).with(Config.log_file, 'a')
          STDERR.should_receive(:reopen).with(STDOUT)

          subject.start
        end

        it "starts the server" do
          Config.server.should_receive(:start)

          subject.start
        end
      end
    end

    context "stop" do
      it "kills the pid found in the pid-file" do
        File.should_receive(:read).with(Config.pid_file).and_return(" 123 ")
        subject.should_receive(:system).with("kill 123")

        subject.stop
      end
    end

  end
end
