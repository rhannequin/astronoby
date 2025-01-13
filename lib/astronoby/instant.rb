# frozen_string_literal: true

require "date"

module Astronoby
  # Represents a specific instant in time using Terrestrial Time (TT) as its
  # internal representation. This class provides conversions between different
  # time scales commonly used in astronomy:
  # - Terrestrial Time (TT)
  # - International Atomic Time (TAI)
  # - Universal Time Coordinated (UTC)
  # - Greenwich Mean Sidereal Time (GMST)
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

    JULIAN_DAY_NUMBER_OFFSET = 0.5

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
        delta_t = Util::Time.terrestrial_universal_time_delta(time)
        terrestrial_time = time.utc.to_datetime.ajd +
          Rational(delta_t, Constants::SECONDS_PER_DAY)
        from_terrestrial_time(terrestrial_time)
      end
    end

    attr_reader :terrestrial_time
    alias_method :tt, :terrestrial_time
    alias_method :julian_date, :terrestrial_time

    # Initialize a new Instant
    #
    # @param terrestrial_time [Numeric] the Terrestrial Time as Julian Date
    # @raise [Astronoby::UnsupportedFormatError] if terrestrial_time is not
    #   numeric
    def initialize(terrestrial_time)
      unless terrestrial_time.is_a?(Numeric)
        raise UnsupportedFormatError, "terrestrial_time must be a Numeric"
      end

      @terrestrial_time = terrestrial_time
      freeze
    end

    # Calculate the time difference between two Instant objects
    #
    # @param other [Astronoby::Instant] another Instant to compare with
    # @return [Numeric] the difference in days
    def diff(other)
      @terrestrial_time - other.terrestrial_time
    end

    # Convert to DateTime (UTC)
    #
    # @return [DateTime] the UTC time as DateTime
    def to_datetime
      DateTime.jd(
        @terrestrial_time -
          Rational(delta_t / Constants::SECONDS_PER_DAY) +
          JULIAN_DAY_NUMBER_OFFSET
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
      to_datetime.to_time.utc
    end

    # Get the ΔT (Delta T) value for this instant
    # ΔT is the difference between TT and UT1
    #
    # @return [Numeric] Delta T in seconds
    def delta_t
      Util::Time.terrestrial_universal_time_delta(@terrestrial_time)
    end

    # Get the Greenwich Mean Sidereal Time
    #
    # @return [Numeric] the sidereal time in radians
    def gmst
      GreenwichSiderealTime.from_utc(to_time).time
    end

    # Get the International Atomic Time (TAI)
    #
    # @return [Numeric] TAI as Julian Date
    def tai
      @terrestrial_time -
        Rational(Constants::TAI_TT_OFFSET, Constants::SECONDS_PER_DAY)
    end

    # Get the Barycentric Dynamical Time (TDB)
    # Note: Currently approximated as equal to TT
    #
    # @return [Numeric] TDB as Julian Date
    def tdb
      # This is technically false, there is a slight difference between TT and
      # TDB. However, this difference is so small that currenly Astronoby
      # doesn't support it and consider they are the same value.
      @terrestrial_time
    end

    # Get the offset between TT and UTC for this instant
    #
    # @return [Numeric] the offset in days
    def utc_offset
      @terrestrial_time - to_time.utc.to_datetime.ajd
    end

    # Calculate hash value for the instant
    #
    # @return [Integer] hash value
    def hash
      [@terrestrial_time, self.class].hash
    end

    # Compare this instant with another
    #
    # @param other [Astronoby::Instant] another instant to compare with
    # @return [Integer, nil] -1, 0, 1 for less than, equal to, greater than;
    #   nil if other is not an Instant
    def <=>(other)
      return unless other.is_a?(self.class)

      @terrestrial_time <=> other.terrestrial_time
    end
    alias_method :eql?, :==
  end
end
