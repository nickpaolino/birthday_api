class BirthdayController < ApplicationController
  def show
    date = params["q"]
    num_of_results = params["results"].to_i

    adapter = Adapter::IMDB.new(date, num_of_results)

    render json: {people: adapter.scrape_pages}
  end
end
