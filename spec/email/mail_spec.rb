require 'spec_helper'

module Basil
  module Email
    describe Mail do
      subject do
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

        described_class.parse(content)
      end

      it_behaves_like "a Dispatchable"

      it "provides header access" do
        subject['Date'].should    == 'A date'
        subject['Subject'].should == 'A subject'
        subject['To'].should      == 'A to address'
        subject['From'].should    == 'A from address'
        subject['Foo'].should     == 'A header with continuation'
      end

      it "has a body" do
        subject.body.should == "Some multi-\nline body"
      end
    end
  end
end
