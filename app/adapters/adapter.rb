require 'open-uri'

module Adapter
  class IMDB
    attr_accessor :date, :num_of_results

    def initialize(date, num_of_results = nil)
      @date = date
      @num_of_results = num_of_results
      stream
    end

    def stream
      return open("http://www.imdb.com/search/name?birth_monthday=05_24&start=1&ref_=rlm")
    end

  end
end
