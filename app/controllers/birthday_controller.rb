class BirthdayController < ApplicationController
  def show
    render json: {birthday: params["q"], results: params["results"]}
  end
end
