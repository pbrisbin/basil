Basil::Plugin.answer(/^echo .*/) do |msg|
  msg.text.gsub(/^echo /, '')
end
