# says will be a little cute with "I am"
Basil.respond_to(/^say (.*)/) {

  says @match_data[1].strip.sub(/^basil\s+is\b/i, 'I am')

}.description = "says what it's told"

# echo is more programmer-friendly and has command substitution
Basil.respond_to(/^echo (.*)/) {

  msg = @match_data[1].strip

  # neat part is it'll do it recursively.
  while msg =~ /(.*)\$\((.*)\)(.*)/
    prefix = $1
    suffix = $3
    result = Basil.dispatch(Basil::Message.new(Basil::Config.me, nil, nil, $2)).text
    msg    = "#{prefix}#{result}#{suffix}"
  end

  says msg

}.description = "says what it's told"
