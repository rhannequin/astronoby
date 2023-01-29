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

    def format
      "#{sign}#{degrees}° #{minutes}′ #{seconds}″"
    end
  end
end
