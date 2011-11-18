Basil::Plugin.respond_to(/^eval (.*)/) {

  retval = nil
  require 'timeout'
  Timeout::timeout(5) do
    Thread.new {
      # use a thread so my $SAFE level isn't affected
      retval = self.instance_eval %{
        $SAFE = 3
        begin
          Config.hide do

            #{@match_data[1]}

          end
        rescue SystemExit
          "don't call exit you dolt"
        end
      }
    }.join
  end

  says "=> #{retval.inspect}"

}.description = 'evaluates ruby expressions'
