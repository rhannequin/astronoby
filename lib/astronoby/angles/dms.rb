# frozen_string_literal: true

module Astronoby
  class Dms
    attr_reader :sign, :degrees, :minutes, :seconds

    def initialize(sign, degrees, minutes, seconds)
      @sign = sign
      @degrees = degrees
      @minutes = minutes
      @seconds = seconds
    end

    def format(precision: 4)
      "#{sign}#{degrees}° #{minutes}′ #{seconds.floor(precision)}″"
    end
  end
end
