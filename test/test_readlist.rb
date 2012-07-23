require 'minitest/autorun'
require 'webmock/minitest'
require './lib/readlist'

class TestReadlist < MiniTest::Unit::TestCase
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
    @stubbed_get = stub_request(:get, "http://readlists.com/api/v1/readlists/075c62a3/")
                                .with(
                                  :body    => {},
                                  :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                                )
                                .to_return(
                                  :status => 200,
                                  :body => '
{"date_added": "2012-06-24T18:05:34", "date_updated": "2012-06-24T18:05:35", "description": "", "entries": [{"article": {"article_title": "Surface: Between a Rock and a Hardware\u00a0Place", "author": "John\u00a0Gruber", "date_published": "2012-06-20 00:00:00", "dek": null, "direction": "ltr", "domain": "daringfireball.net", "excerpt": "Watching the Microsoft Surface event video, I sensed uneasiness. Not panic, but discomfort. Some will argue that I&#x2019;m simply spoiled by Apple&#x2019;s on-stage polish, but Monday&#x2019;s&hellip;", "id": "bwcylm5k", "lead_image_url": null, "next_page_id": null, "rendered_pages": 1, "short_url": "http://rdd.me/bwcylm5k", "total_pages": 0, "url": "http://daringfireball.net/2012/06/surface_between_rock_and_hardware_place", "word_count": 1388}, "article_url": "http://daringfireball.net/2012/06/surface_between_rock_and_hardware_place", "date_added": "2012-06-24T18:05:35", "date_updated": "2012-06-24T18:05:35", "description": "Watching the Microsoft Surface event video, I sensed uneasiness. Not panic, but discomfort. Some will argue that I&#x2019;m simply spoiled by Apple&#x2019;s on-stage polish, but Monday&#x2019;s&hellip;", "entry_title": "Surface: Between a Rock and a Hardware\u00a0Place", "id": "87310", "ordering": 1, "resource_uri": "/api/v1/readlists/075c62a3/entries/87310/"}], "id": "075c62a3", "is_from_edit_id": false, "is_owner": false, "readlist_title": "Untitled Readlist", "resource_uri": "/api/v1/readlists/075c62a3/", "user": null}')

    @stubbed_get_with_articles = stub_request(:get, "http://readlists.com/api/v1/readlists/12345/")
                                .with(
                                  :body    => {},
                                  :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                                )
                                .to_return(
                                  :status => 200,
                                  :body => '
{"date_added": "2012-06-24T18:05:34", "date_updated": "2012-06-24T18:05:35", "description": "", "entries": [{"article": {"article_title": "Surface: Between a Rock and a Hardware\u00a0Place", "author": "John\u00a0Gruber", "date_published": "2012-06-20 00:00:00", "dek": null, "direction": "ltr", "domain": "daringfireball.net", "excerpt": "Watching the Microsoft Surface event video, I sensed uneasiness. Not panic, but discomfort. Some will argue that I&#x2019;m simply spoiled by Apple&#x2019;s on-stage polish, but Monday&#x2019;s&hellip;", "id": "bwcylm5k", "lead_image_url": null, "next_page_id": null, "rendered_pages": 1, "short_url": "http://rdd.me/bwcylm5k", "total_pages": 0, "url": "http://daringfireball.net/2012/06/surface_between_rock_and_hardware_place", "word_count": 1388}, "article_url": "http://daringfireball.net/2012/06/surface_between_rock_and_hardware_place", "date_added": "2012-06-24T18:05:35", "date_updated": "2012-06-24T18:05:35", "description": "Watching the Microsoft Surface event video, I sensed uneasiness. Not panic, but discomfort. Some will argue that I&#x2019;m simply spoiled by Apple&#x2019;s on-stage polish, but Monday&#x2019;s&hellip;", "entry_title": "Surface: Between a Rock and a Hardware\u00a0Place", "id": "87310", "ordering": 1, "resource_uri": "/api/v1/readlists/075c62a3/entries/87310/"}], "id": "075c62a3", "is_from_edit_id": false, "is_owner": false, "readlist_title": "Untitled Readlist", "resource_uri": "/api/v1/readlists/075c62a3/", "user": null}')


    @stubbed_put = stub_request(:put, "http://readlists.com/api/v1/readlists/075c62a3/")
                                .with(
                                  :body    => /.*/,
                                  :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                                )
                                .to_return(
                                  :status => 204,
                                  :headers => {}
                                )

    @stubbed_create_entry = stub_request(:post, "http://readlists.com/api/v1/readlists/075c62a3/entries/")
                                .with(
                                  :body    => {"article_url" => "http://www.bbc.co.uk/news/business-18944097"},
                                  :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}
                                )
                                .to_return(
                                  :status => 201,
                                  :headers => {
                                    "Location"   => "http://readlists.com/api/v1/readlists/075c62a3/entries/113561/",
                                  })

  end

  def test_creates_anonymous_readlist
    readlist = Readlist.create

    assert_equal 'http://readlists.com/api/v1/readlists/075c62a3/', readlist.url
  end

  def test_stores_session_for_future_requests
    readlist = Readlist.create
    assert_equal "2847c36286d39d7f10f7c0a9b6a1dd48", readlist.session_id
  end

  def test_gets_title_and_description
    readlist = Readlist.create
    assert "Untitled Readlist", readlist.title
    assert "", readlist.description
  end

  def test_persists_title_and_description
    readlist = Readlist.create
    # Ensure defaults
    assert "Untitled Readlist", readlist.title
    assert "", readlist.description

    # Set properties
    readlist.title = "My Readlist"
    readlist.description = "A list of reads"

    # Check they've been persisted
    assert "My Readlist", readlist.title
    assert "A list of reads", readlist.description
  end

  def test_gets_article_list
    readlist = Readlist.new(:url => 'http://readlists.com/api/v1/readlists/12345/')

    assert_equal 1, readlist.articles.length
    assert_equal readlist.articles.first.entry_title, "Surface: Between a Rock and a Hardware\u00a0Place"
  end

  def test_persists_articles
    readlist = Readlist.create
    readlist.add_article("http://www.bbc.co.uk/news/business-18944097")
    assert_requested @stubbed_create_entry
  end

  # :todo move into own unit test
  def test_extracts_id_from_url
    util = Class.new do
      include Readlist::Util
    end.new

    assert_equal "12345",    util.extract_id_from_url("http://readlists.com/api/v1/readlists/12345/")
    assert_equal "075c62a3", util.extract_id_from_url("http://readlists.com/api/v1/readlists/075c62a3/")
    assert_equal nil,        util.extract_id_from_url("http://www.bbc.co.uk/news/business-18944097")
  end

  def test_exposes_epub_url
    readlist = Readlist.new(:url => 'http://readlists.com/api/v1/readlists/12345/')
    assert_equal "http://readlists.com/12345/download/epub", readlist.epub_url
  end

end