module Adapter
  class IMDB
    attr_accessor :date, :num_of_results

    def initialize(date, num_of_results = nil)
      @date = date
      @num_of_results = num_of_results
    end

  end
end
