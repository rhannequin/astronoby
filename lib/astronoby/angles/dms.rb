# frozen_string_literal: true

module Astronoby
  class Dms
    attr_reader :degrees, :minutes, :seconds

    def initialize(degrees, minutes, seconds)
      @degrees = degrees
      @minutes = minutes
      @seconds = seconds
    end

    def format
      "#{degrees}° #{minutes}′ #{seconds}″"
    end
  end
end
