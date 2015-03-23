require 'nokogiri'
require 'open-uri'

url = ARGV[0] || "http://habrahabr.ru/company/zfort/"

filters = { it:      ["Дайджест", "IT"],
            php:     [],
            webdev:  [],
            python:  [],
            bigdata: []
          }

filter = filters[:it]

data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))

titles = data.css('.post_title').map { |title| title.text if title.text =~ /#{filter[0]}.*#{filter[1]}/ }.compact
numbers = titles.map { |title| title.match(/№\d*/)[0][1..-1] }

info = numbers.zip(titles)

# info[0] - number of digest
# info[1] - title
info.each do |post|
  puts [post[0], post[1]].join(", ")
end

