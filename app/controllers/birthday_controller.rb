class BirthdayController < ApplicationController
  def show
    # gets the date from the params
    date = params["q"]

    # if a result param was specified then
    if (params["results"])
      # assign to results parameter for class instance
      num_of_results = params["results"].to_i
    else
      # otherwise set default results as 10
      num_of_results = 10
    end

    # create instance of IMDB Adapter to scrape results
    adapter = Adapter::IMDB.new(date, num_of_results)

    # render the results as JSON
    render json: {people: adapter.scrape_pages}
  end
end
