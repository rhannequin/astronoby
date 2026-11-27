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
  # - Coordinated Universal Time (UTC)
  # - Greenwich Mean Sidereal Time (GMST)
  #
  # TAI and TDB are delegated to the horologium gem, which owns the scales
  # that convert by definition or by model. UT1 is not: it rests on
  # observations of the rotation of the Earth, and comes from
  # {Astronoby::DeltaT}. UTC differs from TT by the leap seconds, read from
  # the iers gem.
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
    # It is a Rational so that it keeps a Rational Julian Date exact, where a
    # Float would round it to about 40 microseconds.
    DATETIME_JD_EPOCH_ADJUSTMENT = Rational(1, 2)

    # Astronoby pins the precision it asks horologium for rather than reading
    # horologium's global default, so a host application configuring
    # horologium for itself cannot change what Astronoby computes.
    #
    # Exact rather than standard: standard would round the Julian Date into a
    # two-part float on the way in, and TAI is a fixed offset from TT, so
    # there is nothing to round it for. It is also the cheaper of the two
    # here, having no conversion to make in either direction.
    PRECISION = :exact

    # TT - TAI, fixed by definition, in seconds.
    TT_MINUS_TAI = Rational("32.184")

    # Exact, unlike {Constants::SECONDS_PER_DAY}, so that a Rational Julian
    # Date stays Rational.
    SECONDS_PER_DAY = 86_400

    MODIFIED_JULIAN_DATE_OFFSET = Rational("2400000.5")
    private_constant :TT_MINUS_TAI, :SECONDS_PER_DAY,
      :MODIFIED_JULIAN_DATE_OFFSET

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
        from_utc_julian_date(time.utc.to_datetime.ajd)
      end

      # Creates a new Instant from a Julian Date in UTC
      #
      # Before 1961, when UTC did not run yet, the Julian Date is read as
      # UT1 and ΔT is added instead of TT - UTC.
      #
      # @param julian_date [Numeric] the Julian Date in UTC
      # @return [Astronoby::Instant] a new Instant object
      def from_utc_julian_date(julian_date)
        from_terrestrial_time(julian_date + tt_minus_utc_at(julian_date))
      rescue IERS::OutOfRangeError
        from_terrestrial_time(
          julian_date + Rational(DeltaT.at(julian_date), SECONDS_PER_DAY)
        )
      end

      # TT - UTC at a UTC Julian Date: 32.184 seconds plus the leap seconds,
      # TAI - UTC. Read from the iers gem, the table horologium and
      # IERS::GMST read too, without going through a horologium instant,
      # which costs several times more on the paths that call it in loops.
      #
      # @api private
      # @param utc_julian_date [Numeric] the Julian Date in UTC
      # @return [Rational] TT - UTC in days
      # @raise [IERS::OutOfRangeError] before 1961
      def tt_minus_utc_at(utc_julian_date)
        tai_minus_utc = IERS::LeapSecond.at(
          mjd: utc_julian_date - MODIFIED_JULIAN_DATE_OFFSET
        )
        (TT_MINUS_TAI + tai_minus_utc) / SECONDS_PER_DAY
      end
    end

    # @return [Numeric] the Terrestrial Time as a Julian Date
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
      @memo = {}
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
      @memo[:to_datetime] ||= DateTime.jd(
        utc_julian_date + DATETIME_JD_EPOCH_ADJUSTMENT
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
      @memo[:delta_t] ||= DeltaT.at(@terrestrial_time)
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
    # Read as a Rational rather than a Float. A Julian Date is around 2.46
    # million, so a single Float rounds to about 47 microseconds of the day,
    # which would coarsen an instant that TT carries exactly.
    #
    # @return [Rational] TAI as Julian Date
    def tai
      @memo[:tai] ||= scale_free_instant
        .as(:julian_date, scale: :tai, as: :rational)
    end

    # Get the Barycentric Dynamical Time (TDB)
    #
    # TDB - TT comes from the Fairhead and Bretagnon series ERFA uses. It
    # peaks around 1.7 milliseconds, so a Float Julian Date would quantise
    # most of the correction away; see {#tai} on the shape.
    #
    # @return [Rational] TDB as Julian Date
    def tdb
      @memo[:tdb] ||= scale_free_instant
        .as(:julian_date, scale: :tdb, as: :rational)
    end

    # Get the offset between TT and UTC for this instant
    #
    # @return [Numeric] the offset in days
    def utc_offset
      @terrestrial_time - utc_julian_date
    end

    # Get the Julian Date in Coordinated Universal Time (UTC)
    #
    # TT - UTC is read at UTC, which is what is being looked for, so it is
    # read once at a first guess and again at the result, which settles it
    # on either side of a leap second. Before 1961, when UTC did not run yet,
    # this is UT1, TT - ΔT, with ΔT read the same way since it is read at UT1
    # when going the other way.
    #
    # @return [Numeric] UTC as Julian Date, a Rational when Terrestrial Time
    #   is one
    def utc_julian_date
      @memo[:utc_julian_date] ||= begin
        guess = @terrestrial_time - self.class.tt_minus_utc_at(@terrestrial_time)
        @terrestrial_time - self.class.tt_minus_utc_at(guess)
      rescue IERS::OutOfRangeError
        guess = @terrestrial_time - Rational(delta_t, SECONDS_PER_DAY)
        @terrestrial_time - Rational(DeltaT.at(guess), SECONDS_PER_DAY)
      end
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

    private

    # The instant as horologium holds it: a point on the timeline with no
    # scale of its own. Building it costs more than reading a Julian Date back
    # out of it, so it is built on the first scale conversion that needs it
    # and never on the paths that only want TT.
    #
    # @return [Horologium::Instant]
    def scale_free_instant
      @memo[:scale_free_instant] ||= Horologium::Instant.from_julian_date(
        @terrestrial_time,
        scale: :tt,
        precision: PRECISION
      )
    end
  end
end
