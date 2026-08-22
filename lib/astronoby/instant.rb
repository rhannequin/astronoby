# frozen_string_literal: true

require "date"
require "horologium"

module Astronoby
  # Represents a specific instant in time using Terrestrial Time (TT) as its
  # internal representation. This class provides conversions between different
  # time scales commonly used in astronomy:
  # - Terrestrial Time (TT)
  # - International Atomic Time (TAI)
  # - Barycentric Dynamical Time (TDB)
  # - Universal Time Coordinated (UTC)
  # - Greenwich Mean Sidereal Time (GMST)
  #
  # TAI, TT and TDB are delegated to the horologium gem. UT1 is not: it rests
  # on observations of the rotation of the Earth rather than on definitions,
  # and comes from {Astronoby::DeltaT}.
  #
  # @example Create an instant from the current time
  #   instant = Astronoby::Instant.from_time(Time.now)
  #   instant.tai  # Get International Atomic Time
  #
  # @example Create an instant from Terrestrial Time
  #   instant = Astronoby::Instant.from_terrestrial_time(2460000.5)
  #
  class Instant
    include Comparable

    # The adjustment value to align our noon-based Julian Date with the
    # midnight-based epoch required by Ruby's `DateTime.jd` constructor.
    # Our internal time values are standard astronomical Julian Dates, which
    # start at noon. `DateTime.jd` expects a day that starts at the preceding
    # midnight. This constant adds 0.5 days (12 hours) to make the conversion.
    DATETIME_JD_EPOCH_ADJUSTMENT = 0.5

    # Astronoby pins the precision rather than reading horologium's global
    # default, so a host application configuring horologium for itself cannot
    # change what Astronoby computes.
    PRECISION = :standard

    class << self
      # Creates a new Instant from a Terrestrial Time value
      #
      # @param terrestrial_time [Numeric] the Terrestrial Time as a Julian Date
      # @return [Astronoby::Instant] a new Instant object
      # @raise [Astronoby::UnsupportedFormatError] if terrestrial_time is not
      #   numeric
      def from_terrestrial_time(terrestrial_time)
        new(terrestrial_time)
      end

      # Creates a new Instant from a Time object
      #
      # @param time [Time] a Time object to convert
      # @return [Astronoby::Instant] a new Instant object
      def from_time(time)
        delta_t = DeltaT.at(time)
        terrestrial_time = time.utc.to_datetime.ajd +
          Rational(delta_t, Constants::SECONDS_PER_DAY)
        from_terrestrial_time(terrestrial_time)
      end

      # Creates a new Instant from a Julian Date in UTC
      #
      # @param julian_date [Numeric] the Julian Date in UTC
      # @return [Astronoby::Instant] a new Instant object
      def from_utc_julian_date(julian_date)
        delta_t = DeltaT.at(julian_date)
        terrestrial_time = julian_date +
          Rational(delta_t, Constants::SECONDS_PER_DAY)
        from_terrestrial_time(terrestrial_time)
      end
    end

    # Initialize a new Instant
    #
    # @param terrestrial_time [Numeric] the Terrestrial Time as Julian Date
    # @raise [Astronoby::UnsupportedFormatError] if terrestrial_time is not
    #   numeric
    def initialize(terrestrial_time)
      unless terrestrial_time.is_a?(Numeric)
        raise UnsupportedFormatError, "terrestrial_time must be a Numeric"
      end

      @instant = Horologium::Instant.from_julian_date(
        terrestrial_time,
        scale: :tt,
        precision: PRECISION
      )
      @memo = {}
      freeze
    end

    # @return [Numeric] the Terrestrial Time as a Julian Date
    def terrestrial_time
      @memo[:terrestrial_time] ||= @instant.as(:julian_date, scale: :tt)
    end
    alias_method :tt, :terrestrial_time
    alias_method :julian_date, :terrestrial_time

    # Calculate the time difference between two Instant objects
    #
    # @param other [Astronoby::Instant] another Instant to compare with
    # @return [Numeric] the difference in days
    def diff(other)
      terrestrial_time - other.terrestrial_time
    end

    # Convert to DateTime (UTC)
    #
    # @return [DateTime] the UTC time as DateTime
    def to_datetime
      @memo[:to_datetime] ||= DateTime.jd(
        precise_terrestrial_time -
          Rational(delta_t, Constants::SECONDS_PER_DAY) +
          DATETIME_JD_EPOCH_ADJUSTMENT
      )
    end

    # Convert to Date (UTC)
    #
    # @return [Date] the UTC date
    def to_date
      to_datetime.to_date
    end

    # Convert to Time (UTC)
    #
    # @return [Time] the UTC time
    def to_time
      @memo[:to_time] ||= to_datetime.to_time.utc
    end

    # Get the ΔT (Delta T) value for this instant
    # ΔT is the difference between TT and UT1
    #
    # @return [Numeric] Delta T in seconds
    def delta_t
      @memo[:delta_t] ||= DeltaT.at(terrestrial_time)
    end

    # Get the Greenwich Mean Sidereal Time
    #
    # @return [Numeric] the sidereal time in hours
    def gmst
      @memo[:gmst] ||= GreenwichMeanSiderealTime.from_utc(to_time).time
    end

    # Get the Greenwich Apparent Sidereal Time
    #
    # @return [Numeric] the sidereal time in hours
    def gast
      @memo[:gast] ||= GreenwichApparentSiderealTime.from_utc(to_time).time
    end

    # Get the Local Mean Sidereal Time
    #
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Numeric] the sidereal time in hours
    def lmst(longitude:)
      LocalMeanSiderealTime.from_utc(to_time, longitude: longitude).time
    end

    # Get the Local Apparent Sidereal Time
    #
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Numeric] the sidereal time in hours
    def last(longitude:)
      LocalApparentSiderealTime.from_utc(to_time, longitude: longitude).time
    end

    # Get the International Atomic Time (TAI)
    #
    # @return [Numeric] TAI as Julian Date
    def tai
      @memo[:tai] ||= @instant.as(:julian_date, scale: :tai)
    end

    # Get the Barycentric Dynamical Time (TDB)
    #
    # @return [Numeric] TDB as Julian Date
    def tdb
      @memo[:tdb] ||= @instant.as(:julian_date, scale: :tdb)
    end

    # Get the offset between TT and UTC for this instant
    #
    # @return [Numeric] the offset in days
    def utc_offset
      Rational(delta_t / Constants::SECONDS_PER_DAY)
    end

    # Calculate hash value for the instant
    #
    # @return [Integer] hash value
    def hash
      [@instant, self.class].hash
    end

    # Compare this instant with another
    #
    # @param other [Astronoby::Instant] another instant to compare with
    # @return [Integer, nil] -1, 0, 1 for less than, equal to, greater than;
    #   nil if other is not an Instant
    def <=>(other)
      return unless other.is_a?(self.class)

      @instant <=> other.instant
    end
    alias_method :eql?, :==

    protected

    # @return [Horologium::Instant] the underlying scale-free instant
    attr_reader :instant

    private

    def precise_terrestrial_time
      @memo[:precise_terrestrial_time] ||=
        @instant.as(:julian_date, scale: :tt, as: :rational)
    end
  end
end
