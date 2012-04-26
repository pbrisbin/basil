require 'test_helper'

class TestStorage < Test::Unit::TestCase
  def setup
    clear_storage!
  end

  def teardown
    clear_storage!
  end

  def test_default_file
    assert_equal '/tmp/basil.pstore', Storage.pstore_file
  end

  def test_storage_works
    assert !File.exist?(Storage.pstore_file)

    Storage.with_storage do |store|
      store[:foo] = :bar
    end

    assert File.exist?(Storage.pstore_file)

    Storage.with_storage do |store|
      assert_equal :bar, store[:foo], "Storage should contain :foo"
    end
  end
end
