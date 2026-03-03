# frozen_string_literal: true

module Astronoby
  # Holds twilight times (civil, nautical, astronomical) for a single day.
  class TwilightEvent
    # @return [Time, nil] morning civil twilight time
    attr_reader :morning_civil_twilight_time

    # @return [Time, nil] evening civil twilight time
    attr_reader :evening_civil_twilight_time

    # @return [Time, nil] morning nautical twilight time
    attr_reader :morning_nautical_twilight_time

    # @return [Time, nil] evening nautical twilight time
    attr_reader :evening_nautical_twilight_time

    # @return [Time, nil] morning astronomical twilight time
    attr_reader :morning_astronomical_twilight_time

    # @return [Time, nil] evening astronomical twilight time
    attr_reader :evening_astronomical_twilight_time

    # @param morning_civil_twilight_time [Time, nil]
    # @param evening_civil_twilight_time [Time, nil]
    # @param morning_nautical_twilight_time [Time, nil]
    # @param evening_nautical_twilight_time [Time, nil]
    # @param morning_astronomical_twilight_time [Time, nil]
    # @param evening_astronomical_twilight_time [Time, nil]
    def initialize(
      morning_civil_twilight_time: nil,
      evening_civil_twilight_time: nil,
      morning_nautical_twilight_time: nil,
      evening_nautical_twilight_time: nil,
      morning_astronomical_twilight_time: nil,
      evening_astronomical_twilight_time: nil
    )
      @morning_civil_twilight_time = morning_civil_twilight_time
      @evening_civil_twilight_time = evening_civil_twilight_time
      @morning_nautical_twilight_time = morning_nautical_twilight_time
      @evening_nautical_twilight_time = evening_nautical_twilight_time
      @morning_astronomical_twilight_time = morning_astronomical_twilight_time
      @evening_astronomical_twilight_time = evening_astronomical_twilight_time
    end
  end
end
