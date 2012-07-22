require 'minitest/autorun'
require 'webmock/minitest'
require './lib/readlist'

class TestReadList < MiniTest::Unit::TestCase
  def test_creates_anonymous_readlist
    readlist = ReadList.new
    refute_nil readlist
  end

  def test_has_url
    stub = stub_request(:post, 'http://readlists.com/api/v1/readlists/')
                    .with(
                      :body    => {},
                      :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                    )
                    .to_return(:status => 201, :headers => { "Location" => "http://readlists.com/api/v1/readlists/075c62a3/"})

    readlist = ReadList.create

    assert_requested stub
    assert_equal readlist.url, 'http://readlists.com/api/v1/readlists/075c62a3/'
  end
end