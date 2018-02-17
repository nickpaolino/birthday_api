require 'open-uri'

module Adapter
  class IMDB
    attr_accessor :date, :num_of_results, :page

    def initialize(date, num_of_results = nil)
      @date = date
      @num_of_results = num_of_results
      @count = 1
    end

    def url
      "http://www.imdb.com/search/name?birth_monthday=#{@date}&start=#{@count}&ref_=rlm"
    end

    def create_page
      # create the Nokogiri object and assign to instance variable
      @page = Nokogiri::HTML(open(url))
    end

    def max_results
      results_HTML = create_page.css('div.desc > span')
      results_string = results_HTML.to_s.split("names")[0].split(" ")[-1]
      results_string.to_i
    end

    def celebrity_items
      # create items from scraping the class containing each actor/actresses info
      @page.css('div.lister-item.mode-detail')
    end

    def get_name(item)
      tag = item.css('h3.lister-item-header > a').to_s
      tag.split("\n")[0].split("> ")[-1]
    end

    def get_photo_url(item)
      item.css('div.lister-item-image').to_s.split("src=")[-1].split(" ")[0][1..-2]
    end

    def get_profile_url(item)
      url_tag = item.css('div.lister-item-image').to_s.split("/name/")[1]
      id = url_tag.split("\"")[0]
      "http://www.imdb.com/name/#{id}"
    end

    def title_url(item)
      item.css('div.lister-item-content > p > a').to_s.split("/title/")[1].split("/")[0]
    end

    def get_title(page)
      page.css("div.title_wrapper > h1").inner_html.split("<")[0][0..-2]
    end

    def get_most_known_work(item)
      url = "http://www.imdb.com/title/#{title_url(item)}"
      begin
        page = Nokogiri::HTML(open(url))
      # rescue Exception => ex
      #   log.error "Error: #{ex}"
      #   retry
      end
      create_most_known_work_response(page, url)
    end

    def create_most_known_work_response(page, url)
      puts "URL IS: #{url}"
      {
        title: get_title(page),
        url: url
      }
    end

    def create_response(item)
      {
        name: get_name(item),
        photoUrl: get_photo_url(item),
        profileUrl: get_profile_url(item),
        mostKnownWork: get_most_known_work(item)
      }
    end

    def scrape_pages
      response = []

      # if a set result amount hasn't been established, find the max possible results to use
      results_limit = @num_of_results || max_results

      # create a while loop that runs until the count reaches the number of possible results for a date
      while (@count < results_limit)
        # query each page
        create_page

        # call the celebrity_items method and assign to a local variable
        items = celebrity_items

        items.each do |item|
          response << create_response(item)
        end

        @count += 50
      end

      puts response.length

      response
    end

  end
end
