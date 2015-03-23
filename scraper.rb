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

filtered_data = data.css('.post_title').select { |title| title.text =~ /#{filter[0]}.*#{filter[1]}/ }
filtered_data = filtered_data.map { |title| title.text }
numbers = filtered_data.map { |title| title.match(/№\d*/)[0][1..-1] }

info = numbers.zip(filtered_data)

# info[0] - number of digest
# info[1] - title
info.each do |post|
  puts [post[0], post[1]].join(", ")
end

