# says will be a little cute with "I am"
Basil.respond_to(/^say (.*)/) {

  says @match_data[1].strip.sub(/^basil\s+is\b/i, 'I am')

}.description = "says what it's told"

# echo is more programmer-friendly and has command substitution
Basil.respond_to(/^echo (.*)/) {

  msg = @match_data[1].strip

  # neat part is it'll do it recursively.
  while m = /(.*)\$\((.*)\)(.*)/.match(msg)
    pref, sub, suf = m.captures

    if reply = Basil.dispatch(Basil::Message.new(Basil::Config.me, @msg.from, @msg.from_name, sub))
      msg = "#{pref}#{reply.text}#{suf}"
    else
      msg = "I'm sorry, `#{sub}' is invalid."
    end
  end

  says msg

}.description = "says what it's told"
