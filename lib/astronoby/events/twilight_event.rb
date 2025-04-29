# frozen_string_literal: true

module Astronoby
  class TwilightEvent
    attr_reader :morning_civil_twilight_time,
      :evening_civil_twilight_time,
      :morning_nautical_twilight_time,
      :evening_nautical_twilight_time,
      :morning_astronomical_twilight_time,
      :evening_astronomical_twilight_time

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
