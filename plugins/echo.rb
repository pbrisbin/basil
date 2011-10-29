Basil::Plugin.respond_to(/^echo (.*)/) do
  #
  # The instance variable match_data holds the holds what was set when
  # your regex was tested
  #
  says @match_data[1]
end
