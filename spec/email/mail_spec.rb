require 'spec_helper'

module Basil
  module Email
    describe Mail do
      it "parses from simple emails" do
        content = [
          'Date: A date',
          'Subject: A subject',
          'To: A to address',
          'From: A from address',
          'Foo: A header with',
          '  continuation',
          '',
          'Some multi-',
          'line body'
        ].join("\r\n") # CRLF

        mail = Mail.parse(content)

        mail['Date'].should    == 'A date'
        mail['Subject'].should == 'A subject'
        mail['To'].should      == 'A to address'
        mail['From'].should    == 'A from address'
        mail['Foo'].should     == 'A header with continuation'
        mail.body.should       == "Some multi-\nline body"
      end

      it "can be dispatched" do
        checker = Plugin.check_email(/a match/) { self }

        mail = Mail.new({'Subject' => 'a match', 'From' => 'me'}, 'a body')

        mail.dispatch.should == checker

        mail = Mail.new({'Subject' => 'no match', 'From' => 'me'}, 'a body')

        mail.dispatch.should be_nil
      end
    end
  end
end
