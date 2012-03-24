require 'test_helper'

class TestConfig < Test::Unit::TestCase
  def test_hide
    [:me, :server_type, :plugins_directory].each do |meth|
      # make sure these things are there to be hidden first
      assert_not_nil Config.send(meth), "Configuration keys should be unhidden"

      # key not found raises runtime error
      assert_raises(RuntimeError) do
        Config.hide do
          Config.send(meth)
        end
      end
    end
  end
end
