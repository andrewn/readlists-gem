require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require "json"
require "ostruct"

class Readlist

  module Util
    def extract_id_from_url(url)
      begin
        url.match(%r{http://readlists.com/api/v1/readlists/(.*)/})[1]
      rescue
        nil
      end
    end
  end

  attr_reader :url, :session_id

  def self.create
    response = RestClient.post('http://readlists.com/api/v1/readlists/', {}.to_json, :content_type => :json, :accept => :json)

    raise "#{response.code} is not a 201 response" unless response.code == 201
    raise "No location given" unless response.headers[:location]

    session_id = response.cookies["sessionid"]

    new({ :url => response.headers[:location], :session_id => session_id })
  end

  include Util

  def initialize(params={})
    @url        = params[:url]
    @session_id = params[:session_id]
  end

  def title
    remote_doc["readlist_title"]
  end

  def title=(new_value)
    response = remote_put({ "readlist_title" => new_value })
    raise "#{response.code} is not a 204 response" unless response.code == 204
  end

  def description
    remote_doc["description"]
  end

  def description=(new_value)
    response = remote_put({ "description" => new_value })
    raise "#{response.code} is not a 204 response" unless response.code == 204
  end

  def articles
    articles = remote_doc["entries"].map { |e|
      OpenStruct.new(e)
    }
  end

  def add_article(article_url)
    response = remote_post({ "article_url" => article_url}, "entries/")
    raise "#{response.code} is not a 201 response" unless response.code == 201
  end

  def epub_url
    id = extract_id_from_url(@url)
    "http://readlists.com/#{id}/download/epub"
  end

  private
  def remote_put(payload)
    RestClient.put(@url, payload.to_json, :cookies => cookies_hash, :content_type => :json, :accept => :json)
  end

  def remote_post(payload, subresource="")
    RestClient.post(@url + subresource, payload.to_json, :cookies => cookies_hash, :content_type => :json, :accept => :json)
  end

  def remote_doc
    response = RestClient.get(@url, :content_type => :json, :accept => :json)
    raise "#{response.code} is not a 200 response" unless response.code == 200
    JSON.parse(response.body)
  end

  def cookies_hash
    { "sessionid" => @session_id }
  end
end