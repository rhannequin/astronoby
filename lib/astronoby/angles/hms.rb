# frozen_string_literal: true

module Astronoby
  class Hms
    attr_reader :hours, :minutes, :seconds

    def initialize(hours, minutes, seconds)
      @hours = hours
      @minutes = minutes
      @seconds = seconds
    end

    def format(precision: 4)
      "#{hours}h #{minutes}m #{seconds.floor(precision)}s"
    end
  end
end
