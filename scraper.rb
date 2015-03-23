require 'nokogiri'
require 'open-uri'

FILTERS = { it:      ["Дайджест", "IT"],
            php:     [],
            webdev:  [],
            python:  [],
            bigdata: []
          }


base_url = ARGV[0] || "http://habrahabr.ru/company/zfort/"
page = 1
csv = []

loop do
  url = base_url + "page#{page}"
  puts url
  data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))

  filter = FILTERS[:it]

  posts = data.css('.post')

  titles = posts.css('.post_title').map{ |title| title.text }
  numbers = titles.map{ |title| title.match(/№\d*/)[0][1..-1] if title.match(/№\d*/) }
  ratings = posts.css('.score').map{ |score| score.text =~ /\d/ ? score.text.to_i : 0 }
  views = posts.css('.pageviews').map{ |views| views.text.to_i }
  stars = posts.css('.favs_count').map{ |stars| stars.text.to_i }
  comments = posts.css('.comments .all').map{ |comments| comments.text.to_i }

  info = numbers.zip(ratings, views, stars, comments, titles)
  info = info.select{ |post| post[5] =~ /#{filter[0]}.*#{filter[1]}/ }

  # post[0] - number of digest
  # post[1] - raings
  # post[2] - views
  # post[3] - stars
  # post[4] - comments
  # post[5] - title
  info.each do |post|
    puts post.join(", ")
  end

  csv += info
  page += 1
  break if data.css('#next_page').empty? || tmp == 'q'
end
