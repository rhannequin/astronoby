# frozen_string_literal: true

module Astronoby
  class Hms
    attr_reader :hours, :minutes, :seconds

    def initialize(hours, minutes, seconds)
      @hours = hours
      @minutes = minutes
      @seconds = seconds
    end

    def format
      "#{hours}h #{minutes}m #{seconds}s"
    end
  end
end
