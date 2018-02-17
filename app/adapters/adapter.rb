require 'open-uri'

module Adapter
  class IMDB
    # establish getters and setters for the two instance parameters
    attr_accessor :date, :num_of_results

    # initialize the instance with date and number of results
    def initialize(date, num_of_results)
      @date = date
      # convert number of results to an integer
      @num_of_results = num_of_results.to_i
      # establish the count for iterating through the IMDB results pages
      @count = 1
    end

    def scrape_pages
      response = []

      # check that the results desired aren't greater than the possible amount
      check_max_results

      # create a while loop that runs until the count reaches the number of possible results for a date
      while (@count < @num_of_results)
        # query each page
        page = create_page

        # call the celebrity_items method and assign to a local variable
        items = celebrity_items(page)

        items.each do |item|
          response << create_response(item)
        end
        puts "Count is: #{@count}"
        @count += 50
      end

      puts response.length

      response
    end

    # all methods below only need to be accessible from within the instance
    private

    def url
      # The url is generated with the date and count instance variable
      "http://www.imdb.com/search/name?birth_monthday=#{@date}&start=#{@count}&ref_=rlm"
    end

    def create_page
      # creates the Nokogiri object for scraping
      Nokogiri::HTML(open(url))
    end

    def check_max_results
      # scrapes the page for the number of available results
      results_HTML = create_page.css('div.desc > span')
      results_string = results_HTML.to_s.split("names")[0].split(" ")[-1]
      # converts the result to an integer so it can be compared to the num_of_results variable
      max = results_string.to_i

      # if the num of results specified is greater than the max possible, assign max to num of results
      if (@num_of_results > max)
        @num_of_results = max
      end
    end

    def celebrity_items(page)
      # create items from scraping the class containing each actor/actresses info
      page.css('div.lister-item.mode-detail')
    end

    def get_name(item)
      tag = item.css('h3.lister-item-header > a').to_s
      if (tag)
        tag.split("\n")[0].split("> ")[-1]
      else
        "Name not found"
      end
    end

    def get_photo_url(item)
      image_tag = item.css('div.lister-item-image').to_s
      if (image_tag)
        image_tag.split("src=")[-1].split(" ")[0][1..-2]
      else
        "Image URL not found"
      end
    end

    def get_profile_url(item)
      url_tag = item.css('div.lister-item-image').to_s
      if (url_tag)
        id = url_tag.split("/name/")[1].split("\"")[0]
        "http://www.imdb.com/name/#{id}"
      else
        "Profile URL not found"
      end
    end

    def title_url(item)
      title_url = item.css('div.lister-item-content > p > a').to_s
      if (title_url)
        title_tag = title_url.split("/title/")[1]
        if (title_tag)
          title_tag.split("/")[0]
        else
          "Title URL not found"
        end
      else
        "Title URL not found"
      end
    end

    def get_title(page)
      # the title is being scraped from the title page rather than the celebrity list
      title_wrapper = page.css("div.title_wrapper > h1").inner_html
      if (title_wrapper)
        title_wrapper.split("<")[0][0..-2]
      else
        "Title not found"
      end
    end

    def get_rating(page)
      rating_tag = page.css('span.rating').inner_text
      if (rating_tag)
        rating_tag.split("/")[0]
      else
        "No Rating"
      end
    end

    def get_director(page)
      director_tag = page.css('div.credit_summary_item > span').inner_text
      if (director_tag.length != 0)
        puts "Director: " + director_tag
        puts director_tag.length
        director_tag.split("\n")[1].strip()
      else
        "No Director Listed"
      end
    end

    def get_most_known_work(item)
      url = "http://www.imdb.com/title/#{title_url(item)}"
      begin
        retries ||= 0
        puts "trying #{retries}"
        page = Nokogiri::HTML(open(url))
      rescue Exception
        retry if (retries += 1) < 3
      end

      create_most_known_work_response(page, url)
    end

    def create_most_known_work_response(page, url)
      puts "URL IS: #{url}"
      begin
        {
          title: get_title(page),
          url: url,
          rating: get_rating(page),
          director: get_director(page)
        }
      end
    end

    def create_response(item)
      {
        name: get_name(item),
        photoUrl: get_photo_url(item),
        profileUrl: get_profile_url(item),
        mostKnownWork: get_most_known_work(item)
      }
    end
  end
end
