# ideas taken from moxy's sandbox_eval
#
#  https://github.com/jondot/moxy/blob/master/lib/moxy/sandbox_eval.rb
#

require 'fakefs/safe'
require 'stringio'
require 'timeout'

module Basil
  class SafeEval
    def initialize(plugin)
      @plugin = plugin
    end

    def evaluate(code)
      FakeFS.activate!
      $stdout = stdout = StringIO.new

      cmd = %{
        FakeFS::FileSystem.clear
        $SAFE = 3

        begin
          #{code}
        
        rescue SystemExit
        end
      }

      result = Thread.new { @plugin.instance_eval(cmd) }.value

      [result, stdout.string]

    rescue SyntaxError
      [nil, nil]
    ensure
      $stdout = STDOUT
      FakeFS.deactivate!
    end
  end
end

Basil::Plugin.respond_to(/^eval (.*)/) {

  require 'timeout'

  retval = stdout = nil

  Basil::Config.hide do
    Timeout::timeout(5) do
      e = Basil::SafeEval.new(self)
      retval, stdout = e.evaluate(@match_data[1].strip)
    end
  end

  if stdout # will be "" unless SyntaxError
    says do |out|
      out << stdout if stdout != ""
      out << " => #{retval.inspect}"
    end
  else
    nil
  end

}.description = 'evaluates ruby expressions'
