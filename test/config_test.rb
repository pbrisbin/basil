require 'test_helper'

class TestConfig < Test::Unit::TestCase
  include Basil

  def test_hide
    [:me, :server_type, :plugins_directory].each do |meth|
      assert_not_nil Config.send(meth), "Configuration keys should be unhidden"

      assert_raises(RuntimeError) do
        Config.hide do
            Config.send(meth)
        end
      end
    end
  end
end
