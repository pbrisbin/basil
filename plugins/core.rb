Basil::Plugin.respond_to('test') {

  says "Hello world from #{self.inspect}!"

}.description = 'tests that the bot is working'

Basil::Plugin.respond_to('source') {

  replies "https://github.com/pbrisbin/basil"

}.description = 'shows a link to my source code'

Basil::Plugin.respond_to('docs') {

  replies "http://pbrisbin.com/static/rdocs/basil/"

}.description = 'shows a link to my documentation'

Basil::Plugin.respond_to('help') {

  out = []

  Basil::Plugin.responders.each do |p|
    next unless p.description
    out << "#{p.regex.inspect} => #{p.description}."
  end

  Basil::Plugin.watchers.each do |p|
    next unless p.description
    out << "#{p.regex.inspect} => #{p.description}."
  end

  says out.join("\n") unless out.empty?

}.description = 'display what I do'

Basil::Plugin.respond_to('reload') {

  a = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.responders.delete_if { true }
  Basil::Plugin.watchers.delete_if { true }

  b = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  Basil::Plugin.load!

  c = Basil::Plugin.responders.length + Basil::Plugin.watchers.length

  says "#{a - b} plugins removed, #{c - b} plugins (re)loaded."

}.description = 'reloads all files in the plugins directory'

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
