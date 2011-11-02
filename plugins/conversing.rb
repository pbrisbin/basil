#
# A simple proof of concept for a conversational plugin
#
Basil::Plugin.respond_to(/^make me an? .*/) {

  unless in_conversation?
    start_conversation

    @command = @match_data[0].strip

    return says "make it yourself."
  end

  end_conversation

  if @msg.text == "sudo #{@command}"
    says "ugh, fine..."
  else
    nil
  end

}
