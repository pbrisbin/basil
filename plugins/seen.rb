Basil.respond_to(/^seen (.+?)\??$/) {

  if msg = chat_history(:from => @match_data[1].strip).first
    @msg.reply "#{msg.from_name} was last seen on #{msg.time.strftime("%D, at %r")} saying \"#{msg.text}\"."
  end

}.description = "displays when the person was last seen in chat"
