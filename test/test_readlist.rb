require 'minitest/autorun'
require 'webmock/minitest'
require './lib/readlist'

class TestReadList < MiniTest::Unit::TestCase
  def setup
    @stubbed_create = stub_request(:post, 'http://readlists.com/api/v1/readlists/')
                                .with(
                                  :body    => {},
                                  :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                                )
                                .to_return(
                                  :status => 201,
                                  :headers => {
                                    "Location"   => "http://readlists.com/api/v1/readlists/075c62a3/",
                                    "Set-Cookie" => "sessionid=2847c36286d39d7f10f7c0a9b6a1dd48; expires=Sun, 05-Aug-2012 14:10:48 GMT; httponly; Max-Age=1209600; Path=/"
                                  })
  end

  def test_creates_anonymous_readlist
    readlist = ReadList.create

    assert_equal 'http://readlists.com/api/v1/readlists/075c62a3/', readlist.url
  end

  def test_stores_session_for_future_requests
    readlist = ReadList.create
    assert_equal "2847c36286d39d7f10f7c0a9b6a1dd48", readlist.session_id
  end
end