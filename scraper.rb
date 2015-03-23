require 'nokogiri'
require 'open-uri'

url = ARGV[0] || "http://habrahabr.ru/company/zfort/"

data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))

data.css('.post_title').each { |title| puts title.text }

