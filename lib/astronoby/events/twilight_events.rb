# frozen_string_literal: true

module Astronoby
  # Holds arrays of twilight times over a time range.
  class TwilightEvents
    # @return [Array<Time>] morning civil twilight times
    attr_reader :morning_civil_twilight_times

    # @return [Array<Time>] evening civil twilight times
    attr_reader :evening_civil_twilight_times

    # @return [Array<Time>] morning nautical twilight times
    attr_reader :morning_nautical_twilight_times

    # @return [Array<Time>] evening nautical twilight times
    attr_reader :evening_nautical_twilight_times

    # @return [Array<Time>] morning astronomical twilight times
    attr_reader :morning_astronomical_twilight_times

    # @return [Array<Time>] evening astronomical twilight times
    attr_reader :evening_astronomical_twilight_times

    # @param morning_civil [Array<Time>] morning civil twilight times
    # @param evening_civil [Array<Time>] evening civil twilight times
    # @param morning_nautical [Array<Time>] morning nautical twilight times
    # @param evening_nautical [Array<Time>] evening nautical twilight times
    # @param morning_astronomical [Array<Time>] morning astronomical twilight
    #   times
    # @param evening_astronomical [Array<Time>] evening astronomical twilight
    #   times
    def initialize(
      morning_civil,
      evening_civil,
      morning_nautical,
      evening_nautical,
      morning_astronomical,
      evening_astronomical
    )
      @morning_civil_twilight_times = morning_civil
      @evening_civil_twilight_times = evening_civil
      @morning_nautical_twilight_times = morning_nautical
      @evening_nautical_twilight_times = evening_nautical
      @morning_astronomical_twilight_times = morning_astronomical
      @evening_astronomical_twilight_times = evening_astronomical
    end
  end
end
