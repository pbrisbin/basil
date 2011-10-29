Basil::Plugin.respond_to(/^echo (.*)/) do |p|
  #
  # Unfortunately, due to the disconnect between the checking of the
  # regex above and the calling of this block, the MatchData is not
  # retained so we are a little less-than-DRY here. I'm open to ways to
  # provide the MatchData from the check in this block. I've tried some
  # things but was met with weird, weird behavior -- I blame the lambda
  # stuff...
  #
  p.says p.msg.text.gsub(/^echo /, '')  
end
