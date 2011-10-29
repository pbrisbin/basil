Basil::Plugin.watch_for(/http:\/\/.*\.com/) do
  #
  # Stupid watch tester, triggers on any message from anyone to anyone
  # that a) is not picked up by a responder first and b) contains that
  # regex.
  #
  says "Saw link #{@match_data[0]}!"
end
