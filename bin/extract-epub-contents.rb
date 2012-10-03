#!/usr/bin/env ruby

#require 'zlib'
require 'pry'

epub_file = Dir['./*.epub'].first
#source = File.open(epub_file) { |f| f.read() }

require 'zip/zipfilesystem'
require 'pdfkit'
require 'fileutils'
require 'nokogiri'

Zip::ZipFile.open(epub_file) do |zipfile|
  zipfile.each do |file|
    puts file
    filepath  = "tmp/#{file}"
    directory = File.dirname(filepath)
    FileUtils.mkpath directory
    File.open(filepath, 'w') {|f| f.write(zipfile.read(file)) }
  end
end

files = [
  "tmp/OEBPS/e_2700741533338266323.html",
  "tmp/OEBPS/e_5047514119736116432.html"
]

contents = ""
files.each do |path|
  File.open(path) do |f|
    base_path = File.dirname File.expand_path(f)
    doc  = Nokogiri::HTML(f.read)
    body = doc.css('body')
    body.css('img').each do |img|
      img[:src] = "file:///#{base_path}/#{img[:src]}"
    end
    puts body.first.inner_html
    contents += body.first.inner_html
  end
end

kit = PDFKit.new(contents)
kit.to_file('output.pdf')
