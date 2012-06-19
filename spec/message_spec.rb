require 'spec_helper'

module Basil
  describe Message do
    it "knows me case insensitively" do
      Config.stub(:me).and_return("me")

      msg = Message.new("Me", "from", "from_name", "text", "chat")
      msg.to_me?.should be_true
    end

    it "can change chats" do
      msg = Message.new("to", "from", "from_name", "text", "chat")
      msg.chat.should == "chat"

      msg.chat = "foo"
      msg.chat.should == "foo"
    end
  end
end
