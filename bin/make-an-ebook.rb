#!/usr/bin/env ruby

require './lib/readlist'
require 'date'
require 'open-uri'

article_urls = [
  "http://www.bbc.co.uk/news/business-18944097",
  "http://blog.easy-designs.net/archives/2011/11/16/on-adaptive-vs-responsive-web-design/",
  "http://www.jayway.com/2012/08/01/combining-html-hypermedia-apis-and-adaptive-web-design/"
]

# Create a readlist
puts "Creating readlist..."
readlist = Readlist.create
readlist.title = "Test readlist"
readlist.description = "Created on #{Date.today.to_s}"

puts "Created: #{readlist.url}"

# Add articles
puts "Adding articles"
article_urls.each do |url|
  begin
    readlist.add_article(url)
  rescue Exception => e
    puts "Error #{e}"
  end
end

# Save epub
file_name = "readlist-#{readlist.id}.epub"
puts "Downloading epub and saving as #{file_name}"
open(file_name, "wb") do |file|
  #open(readlist.epub_url) do |uri|
  #   file.write(uri.read)
  #end
  file.write(readlist.epub)
end

puts "done."