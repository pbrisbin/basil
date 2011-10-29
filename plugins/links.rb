Basil::Plugin.watch_for(/http:\/\/.*\.com/) do |p|
  #
  # Stupid watch tester, triggers on any message from anyone to anyone
  # that a) is not picked up by a responder first and b) contains that
  # regex.
  #
  p.says "A link!"
end
