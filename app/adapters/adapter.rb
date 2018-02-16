require 'open-uri'

module Adapter
  class IMDB
    attr_accessor :date, :num_of_results, :page

    def initialize(date, num_of_results = nil)
      @date = date
      @num_of_results = num_of_results
      @count = 1
    end

    def stream
      return open("http://www.imdb.com/search/name?birth_monthday=#{@date}&start=#{@count}&ref_=rlm")
    end

    def create_body
      if (stream.content_encoding.empty?)
        return stream.read
      else
        return Zlib::GzipReader.new(stream).read
      end
    end

    def create_page
      # create the Nokogiri object and assign to instance variable
      @page = Nokogiri::HTML(create_body)
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
          response << get_name(item)
        end

        @count += 50
      end

      puts response.length

      response
    end

  end
end
