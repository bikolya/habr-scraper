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

titles = data.css('.post_title').map{ |title| title.text }.compact
numbers = titles.map{ |title| title.match(/№\d*/)[0][1..-1] }
ratings = data.css('.score').map{ |score| score.text =~ /\d/ ? score.text.to_i : 0 }.compact

info = numbers.zip(ratings, titles)
info = info.select{ |post| post[2] =~ /#{filter[0]}.*#{filter[1]}/ }

# info[0] - number of digest
# info[1] - title
# info[2] - title
info.each do |post|
  puts [post[0], post[1], post[2]].join(", ")
end

