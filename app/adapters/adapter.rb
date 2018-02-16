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
      @page = Nokogiri::HTML(create_body)
    end

    def max_results
      results_HTML = @page.css('div.desc > span')
      results_string = results_HTML.to_s.split("names")[0].split(" ")[-1]
      results_string.to_i
    end

    def scrape_pages
      response = []

      # create the Nokogiri object and assign to instance variable
      create_page

      # create a while loop that runs until the count reaches the number of possible results for a date
      while (@count < max_results)
        # query each page
      end
    end
  end
end
