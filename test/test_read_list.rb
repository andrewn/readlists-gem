require 'minitest/autorun'
require './lib/read_list'

class TestReadList < MiniTest::Unit::TestCase
  def test_creates_anonymous_read_list
    read_list = ReadList.new
    refute_nil read_list
  end
end