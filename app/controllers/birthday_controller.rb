class BirthdayController < ApplicationController
  def show
    date = params["q"]
    num_of_results = params["results"]
    render json: {birthday: date, results: num_of_results}
  end
end
