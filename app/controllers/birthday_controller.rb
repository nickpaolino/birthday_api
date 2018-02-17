class BirthdayController < ApplicationController
  def show
    date = params["q"]
    if (params["results"])
      num_of_results = params["results"].to_i
    end

    adapter = Adapter::IMDB.new(date, num_of_results)

    render json: {people: adapter.scrape_pages}
  end
end
