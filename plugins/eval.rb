# ideas taken from moxy's sandbox_eval
#
#  https://github.com/jondot/moxy/blob/master/lib/moxy/sandbox_eval.rb
#
require 'fakefs/safe'
require 'stringio'
require 'timeout'

Sandbox = Struct.new(:plugin, :msg, :code) do
  def evaluate
    result = sandboxed do
      plugin.instance_eval(<<-EOC)
        FakeFS::FileSystem.clear

        $SAFE = 3

        begin; #{code} end
      EOC
    end

    str = @stdout.string

    msg.say str if str != ''
    msg.say "=> #{result.inspect}"

  rescue Exception => ex
    msg.say "Error: #{ex}"
    Basil.logger.warn ex
  end

  private

  def sandboxed(&block)
    setup

    Basil::Config.hide do
      Timeout::timeout(5) do
        # thread required to isolate SAFE value
        Thread.new { yield }.value
      end
    end
  ensure
    teardown
  end

  def setup
    FakeFS.activate!
    $stdout = @stdout = StringIO.new
  end

  def teardown
    $stdout = STDOUT
    FakeFS.deactivate!
  end
end

Basil.respond_to(/^eval (.*)/) {

  Sandbox.new(self, @msg, @match_data[1].strip).evaluate

}.description = 'evaluates ruby expressions'
