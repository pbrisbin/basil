require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'basil'

module Basil
  Loggers.level = 6 # OFF

  shared_examples_for "a Dispatchable" do
    it "must respond to template methods" do
      subject.should respond_to(:match?)
      subject.should respond_to(:each_plugin)
    end

    it "must be coercible to Message" do
      subject.to_message.should be_a(Message)
    end
  end

  shared_examples_for "a Server" do
    it "should respond to the template methods" do
      subject.should respond_to(:main_loop)
      subject.should respond_to(:accept_message)
      subject.should respond_to(:send_message)
    end
  end
end
