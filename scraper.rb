require 'nokogiri'
require 'open-uri'

url = ARGV[0]

data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))

puts data.css('.post_title').text