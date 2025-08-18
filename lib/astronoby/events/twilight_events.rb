# frozen_string_literal: true

module Astronoby
  class TwilightEvents
    attr_reader :morning_civil_twilight_times,
      :evening_civil_twilight_times,
      :morning_nautical_twilight_times,
      :evening_nautical_twilight_times,
      :morning_astronomical_twilight_times,
      :evening_astronomical_twilight_times

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
