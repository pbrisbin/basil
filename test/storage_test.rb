require 'test_helper'

class TestStorage < Test::Unit::TestCase
  def setup
    @pstore_file = '/tmp/basil.pstore'
  end

  def teardown
    File.unlink(@pstore_file)
  end

  def test_uses_default_file
    assert !File.exist?(@pstore_file)

    Storage.with_storage do |store|
      store[:key] = :val
    end

    assert File.exist?(@pstore_file)
  end

  def test_storage_works
    Storage.with_storage do |store|
      store[:foo] = :bar
    end

    Storage.with_storage do |store|
      assert_equal :bar, store[:foo], "Storage should contain :foo"
    end
  end
end
