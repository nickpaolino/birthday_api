class BirthdayController < ApplicationController
  def show
    date = params["q"]
    num_of_results = params["results"]

    adapter = Adapter::IMDB.new(date)

    render json: {birthday: adapter.date, results: num_of_results}
  end
end
