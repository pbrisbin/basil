require 'spec_helper'

module Basil
  describe Cli do
    subject { described_class.new }

    it_behaves_like "a Server"
  end
end
