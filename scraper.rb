require 'nokogiri'
require 'open-uri'
require 'csv'

class Scraper
  attr_accessor :titles, :numbers, :ratings, :views, :stars, :comments

  FILTERS = { it:      ["Дайджест", "IT", "айти"],
              php:     ["Дайджест", "PHP", "PHP"],
              webdev:  ["Несколько", "интересностей", "полезностей"],
              python:  ["Python", "digest", "Новости"],
              bigdata: ["Обзор", "анализу", "обучению"]
            }

  def scrape_to_csv(base_url, filter, dest)
    page = 1
    result = []
    loop do
      url = base_url + "page#{page}"
      data = Nokogiri::HTML(open(url, "User-Agent" => "Mac Safari"))
      posts = data.css('.post')
      set_data(posts)

      info = zip_all
      info = filtered(info, filter)

      page += 1
      result += info
      break if data.css('#next_page').empty?
    end

    result.sort_by!(&:first)
    write_to_csv(result, dest)
  end

  private

    def set_data(posts)
      @titles = posts.css('.post_title').map{ |title| title.text }
      @numbers = @titles.map{ |title| title.gsub(/[\s\-]/, "").match(/[№#]\d*/)[0][1..-1].to_i if title.match(/№\d*/) }
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
        post[5] =~ /#{filter[0]}.*#{filter[1]}/ || post[5] =~ /#{filter[0]}.*#{filter[2]}/ && post[0]
      end
    end

    def write_to_csv(data, dest)
      CSV.open(dest, "w") do |csv|
        data.each do |post|
          csv << post
        end
      end
    end
end


start = Time.now
base_url = ARGV[0] || "http://habrahabr.ru/company/zfort/"
filter = (ARGV[1] || "it").to_sym
dest = ARGV[2] || "it.csv"

scraper = Scraper.new
scraper.scrape_to_csv(base_url, Scraper::FILTERS[filter], dest)

finish = Time.now
puts "Completed in #{finish - start}"

# csv[0] - number of digest
# csv[1] - raings
# csv[2] - views
# csv[3] - stars
# csv[4] - comments
# csv[5] - title
