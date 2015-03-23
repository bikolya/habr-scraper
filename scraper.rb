require 'nokogiri'
require 'open-uri'

class Scraper

  attr_accessor :base_url, :filter, :titles, :numbers, :ratings, :views, :stars, :comments

  FILTERS = { it:      ["Дайджест", "IT", "айти"],
              php:     [],
              webdev:  [],
              python:  [],
              bigdata: []
            }

  def initialize
  end

  def set_data(posts)
    @titles = posts.css('.post_title').map{ |title| title.text }
    @numbers = @titles.map{ |title| title.gsub(/[\s\-]/, "").match(/[№#]\d*/)[0][1..-1].to_i if title.match(/№\d*/) }.compact
    @ratings = posts.css('.score').map{ |score| score.text =~ /\d/ ? score.text.to_i : 0 }
    @views = posts.css('.pageviews').map{ |views| views.text.to_i }
    @stars = posts.css('.favs_count').map{ |stars| stars.text.to_i }
    @comments = posts.css('.comments .all').map{ |comments| comments.text.to_i }
  end

  def zip_all
    @numbers.zip(@ratings, @views, @stars, @comments, @titles)
  end

  def filtered(info, filter)
    info.select do |post|
      post[5] =~ /#{filter[0]}.*#{filter[1]}/ || post[5] =~ /#{filter[0]}.*#{filter[2]}/
    end
  end

  def scrape_to_csv(base_url, filter)
    page = 1
    csv = []
    loop do
      start = Time.now
      url = base_url + "page#{page}"
      data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))
      posts = data.css('.post')
      set_data(posts)

      info = zip_all
      info = filtered(info, filter)

      page += 1
      csv += info
      finish = Time.now
      puts finish - start
      break if data.css('#next_page').empty?
    end

    csv
  end

end


start = Time.now
base_url = "http://habrahabr.ru/company/zfort/"
scraper = Scraper.new
csv = scraper.scrape_to_csv(base_url, Scraper::FILTERS[:it])

csv.each do |post|
  puts post[0]
end
csv.sort_by!(&:first)

# csv[0] - number of digest
# csv[1] - raings
# csv[2] - views
# csv[3] - stars
# csv[4] - comments
# csv[5] - title

csv.each do |post|
  puts post.join(", ")
end

finish = Time.now
puts finish - start
