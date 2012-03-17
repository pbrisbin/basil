Basil.respond_to(/canadize (.+)/) do
  says "#{@match_data[1]}, eh?"
end
