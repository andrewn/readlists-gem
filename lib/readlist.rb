require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require "json"

class ReadList
  attr_reader :url

  def self.create
    response = RestClient.post('http://readlists.com/api/v1/readlists/', {}.to_json, :content_type => :json, :accept => :json)

    raise "#{response.code} is not a 201 response" unless response.code == 201
    raise "No location given" unless response.headers[:location]

    new({ :url => response.headers[:location] })
  end

  def initialize(params={})
    @url = params[:url]
  end
end