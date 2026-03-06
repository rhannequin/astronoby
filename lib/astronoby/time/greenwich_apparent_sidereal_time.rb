# frozen_string_literal: true

module Astronoby
  # Greenwich Apparent Sidereal Time (GAST). Derived from GMST by applying
  # the equation of the equinoxes (nutation correction).
  class GreenwichApparentSiderealTime < GreenwichSiderealTime
    # Creates GAST from UTC by computing GMST and applying the equation
    # of the equinoxes.
    #
    # @param utc [Time] the UTC time
    # @return [Astronoby::GreenwichApparentSiderealTime]
    def self.from_utc(utc)
      gmst = GreenwichMeanSiderealTime.from_utc(utc)
      instant = Instant.from_time(utc)
      nutation = Nutation.new(instant: instant)
      mean_obliquity = MeanObliquity.at(instant)

      equation_of_equinoxes = nutation.nutation_in_longitude.hours *
        mean_obliquity.cos
      gast_time = normalize_time(gmst.time + equation_of_equinoxes)

      new(date: gmst.date, time: gast_time)
    end

    # @param date [Date] the calendar date
    # @param time [Numeric] GAST in hours
    def initialize(date:, time:)
      super(date: date, time: time, type: APPARENT)
    end
  end
end
