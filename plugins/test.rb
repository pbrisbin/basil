Basil::Plugin.respond_to(/^test$/) do |p|
  #
  # Inside this block, p has a method msg which contains the
  # Basil::Message you're processing (time, to, from, and text). p
  # itself also provides the helper methods say, reply, and forward
  #
  p.replies "Hello from #{p.inspect}!"
end
