module Adapter
  class IMDB
    def initialize(date, num_of_results = nil)
      @date = date
      @num_of_results = num_of_results
    end

    def date
      @date
    end

    def num_of_results
      @num_of_results
    end
  end
end
