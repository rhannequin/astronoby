# frozen_string_literal: true

module Astronoby
  # Finds when a body reaches a given altitude above the observer's horizon.
  #
  # The window is split at the body's culminations, since between a lower and
  # the next upper culmination the altitude only goes one way. A segment whose
  # ends lie on opposite sides of the target holds exactly one crossing, which
  # is located on the real altitude. A segment where the target is within
  # {GRAZING_MARGIN} of an end could hold two crossings or none, so it is
  # sampled and bisected instead.
  #
  # The calculator holds no state between calls: every call searches with its
  # own cache of evaluated positions, so one instance can be shared by threads.
  class AltitudeCrossingCalculator
    REFERENCES = [:center, :upper_limb, :lower_limb].freeze
    DIRECTIONS = [:rising, :setting].freeze

    TAU = Math::PI * 2
    SIDEREAL_RATE = TAU * 1.00273790935

    # A culmination is at most about 0.52 days after the previous one (the
    # Moon's), so this much on each side of the window brackets its ends.
    CULMINATION_PADDING_IN_DAYS = 0.6

    ALTITUDE_TOLERANCE = Angle.from_degrees(1e-5).radians
    # A Float Julian Date resolves about 47 µs, or 3.4e-9 rad of hour angle,
    # so a tighter tolerance could never be met.
    HOUR_ANGLE_TOLERANCE = 1e-8
    # The ends of a segment only have to be close enough to the culminations
    # for the altitude there to be within GRAZING_MARGIN of the extremum, which
    # a hundred microradians of hour angle is, except for a body passing within
    # a few thousandths of a degree of the zenith.
    SEGMENT_HOUR_ANGLE_TOLERANCE = 1e-4
    GRAZING_MARGIN = Angle.from_degrees(0.05).radians
    # A Newton step from an altitude this close to the target lands within
    # {ALTITUDE_TOLERANCE} of it, for a slope that is off by up to 2%, so the
    # step is returned without evaluating the body there.
    NEWTON_ACCEPT = Angle.from_degrees(5e-4).radians
    MAX_ITERATIONS = 30

    FALLBACK_SAMPLES_PER_DAY = 288
    DIRECTION_PROBE_IN_DAYS = 60.0 / Constants::SECONDS_PER_DAY
    DUPLICATE_THRESHOLD_IN_DAYS = 1e-6

    Sample = Struct.new(:hour_angle, :declination, :altitude)
    Culmination = Struct.new(:kind, :tt)
    Crossing = Struct.new(:tt, :direction, :grazing)

    # @param body [Class, Object] celestial body to track
    # @param observer [Astronoby::Observer] observer location
    # @param ephem [::Ephem::SPK, nil] ephemeris data source
    # @param refraction [Boolean] whether to apply atmospheric refraction to
    #   the altitude, false by default as in the twilight convention
    # @param reference [Symbol] the point of the body that reaches the target:
    #   +:center+, +:upper_limb+ or +:lower_limb+, the limbs using the body's
    #   true semi-diameter
    def initialize(
      body:,
      observer:,
      ephem: nil,
      refraction: false,
      reference: :center
    )
      unless REFERENCES.include?(reference)
        raise IncompatibleArgumentsError,
          "Only #{REFERENCES.join(", ")} are allowed as reference, " \
          "got #{reference}"
      end

      unless body.respond_to?(:at)
        raise IncompatibleArgumentsError,
          "The body must respond to #at(instant, ephem:), got #{body}"
      end

      if reference != :center && !(body.is_a?(Class) && body <= SolarSystemBody)
        raise IncompatibleArgumentsError,
          "A limb reference needs a body with a known size, got #{body}"
      end

      @body = body
      @observer = observer
      @ephem = ephem
      @refraction = refraction
      @reference = reference
    end

    # @param start_time [Time] start of the window
    # @param end_time [Time] end of the window
    # @param altitude [Astronoby::Angle] the altitude to reach, positive or
    #   negative
    # @return [Array<Astronoby::AltitudeCrossing>] the crossings in the window,
    #   sorted by time
    def crossings_between(start_time, end_time, altitude:)
      multiple_crossings_between(start_time, end_time, altitudes: [altitude])
        .first
    end

    # Same as {#crossings_between} for several altitudes at once, sharing the
    # culminations and the evaluated positions between them.
    #
    # @param start_time [Time] start of the window
    # @param end_time [Time] end of the window
    # @param altitudes [Array<Astronoby::Angle>] the altitudes to reach
    # @return [Array<Array<Astronoby::AltitudeCrossing>>] the crossings of each
    #   altitude, in the order of +altitudes+
    def multiple_crossings_between(start_time, end_time, altitudes:)
      search_between(start_time, end_time).crossings(altitudes)
    end

    # @param date [Date] the day
    # @param altitude [Astronoby::Angle] the altitude to reach
    # @param direction [Symbol] +:rising+ or +:setting+
    # @param utc_offset [String, Integer] UTC offset of the day, e.g.
    #   "+02:00"
    # @return [Astronoby::AltitudeCrossing, nil] the first crossing of that
    #   direction from midnight to the next midnight, if any
    def crossing_on(date, altitude:, direction:, utc_offset: 0)
      unless DIRECTIONS.include?(direction)
        raise IncompatibleArgumentsError,
          "Only #{DIRECTIONS.join(" or ")} are allowed as direction, " \
          "got #{direction}"
      end

      start_time = Time.new(date.year, date.month, date.day, 0, 0, 0, utc_offset)
      following = date.next_day
      end_time = Time.new(
        following.year, following.month, following.day, 0, 0, 0, utc_offset
      )

      crossings_between(start_time, end_time, altitude: altitude)
        .find do |crossing|
          crossing.direction == direction &&
            crossing.instant.to_time < end_time
        end
    end

    # @param start_time [Time] start of the window
    # @param end_time [Time] end of the window
    # @return [Array<Astronoby::AltitudeExtreme>] the upper and lower
    #   culminations in the window, sorted by time, with the altitude of the
    #   reference point at each
    def extremes_between(start_time, end_time)
      search_between(start_time, end_time).extremes
    end

    private

    def search_between(start_time, end_time)
      if end_time < start_time
        raise IncompatibleArgumentsError,
          "The end of the window must not be before its start"
      end

      Search.new(
        body: @body,
        observer: @observer,
        ephem: @ephem,
        refraction: @refraction,
        reference: @reference,
        start_tt: Instant.from_time(start_time).tt.to_f,
        end_tt: Instant.from_time(end_time).tt.to_f
      )
    end

    class Search
      def initialize(
        body:,
        observer:,
        ephem:,
        refraction:,
        reference:,
        start_tt:,
        end_tt:
      )
        @body = body
        @observer = observer
        @ephem = ephem
        @refraction = refraction
        @reference = reference
        @start_tt = start_tt
        @end_tt = end_tt
        @samples = {}
      end

      def crossings(altitudes)
        overlapping = segments

        altitudes.map do |altitude|
          target = altitude.radians

          overlapping
            .flat_map { |first, last| segment_crossings(first, last, target) }
            .sort_by(&:tt)
            .then { |crossings| remove_duplicates(crossings) }
            .map { |crossing| build_crossing(crossing) }
        end
      end

      def extremes
        culminations(@start_tt, @end_tt, HOUR_ANGLE_TOLERANCE).map do |culmination|
          AltitudeExtreme.new(
            kind: culmination.kind,
            instant: Instant.from_terrestrial_time(culmination.tt),
            altitude: Angle.from_radians(altitude_at(culmination.tt))
          )
        end
      end

      private

      def sample_at(tt)
        @samples[tt] ||= begin
          instant = Instant.from_terrestrial_time(tt)
          body = @body.at(instant, ephem: @ephem)
          equatorial = body.observed_by(@observer).equatorial
          hour_angle = equatorial.compute_hour_angle(
            time: instant.to_time,
            longitude: @observer.longitude
          )
          declination = equatorial.declination

          Sample.new(
            hour_angle.radians,
            declination.radians,
            reference_altitude(body, declination, hour_angle)
          )
        end
      end

      def reference_altitude(body, declination, hour_angle)
        latitude = @observer.latitude
        sin_altitude = latitude.sin * declination.sin +
          latitude.cos * declination.cos * hour_angle.cos
        altitude = Angle.asin(sin_altitude.clamp(-1.0, 1.0))

        if @refraction
          altitude += Refraction.angle(
            coordinates: Coordinates::Horizontal.new(
              azimuth: Angle.zero,
              altitude: altitude,
              observer: @observer
            )
          )
        end

        altitude.radians + limb_offset(body)
      end

      def limb_offset(body)
        case @reference
        when :upper_limb then body.angular_diameter.radians / 2
        when :lower_limb then -body.angular_diameter.radians / 2
        else 0.0
        end
      end

      def altitude_at(tt)
        sample_at(tt).altitude
      end

      def hour_angle_at(tt)
        sample_at(tt).hour_angle
      end

      def wrap(radians)
        (radians + Math::PI) % TAU - Math::PI
      end

      def segments
        culminations(
          @start_tt - CULMINATION_PADDING_IN_DAYS,
          @end_tt + CULMINATION_PADDING_IN_DAYS,
          SEGMENT_HOUR_ANGLE_TOLERANCE
        ).each_cons(2).select do |first, last|
          last.tt >= @start_tt && first.tt <= @end_tt
        end
      end

      def culminations(start_tt, end_tt, tolerance)
        start_hour_angle = hour_angle_at(start_tt)
        spacing = TAU / SIDEREAL_RATE

        {
          AltitudeExtreme::UPPER_CULMINATION => 0.0,
          AltitudeExtreme::LOWER_CULMINATION => Math::PI
        }.flat_map do |kind, hour_angle|
          tt = start_tt +
            ((hour_angle - start_hour_angle) % TAU) / SIDEREAL_RATE
          previous = nil
          found = []

          while tt <= end_tt
            tt = refine_culmination(tt, hour_angle, tolerance)
            found << Culmination.new(kind, tt) if tt.between?(start_tt, end_tt)
            # Step from the refined event: a sidereal day drifts from the
            # Moon's by about an hour per day, which would add up over a
            # window. Once two are known their spacing, shared by both kinds,
            # is a closer step than a sidereal day, as it changes slowly from
            # one day to the next.
            spacing = tt - previous if previous
            previous = tt
            tt += spacing
          end

          found
        end.sort_by(&:tt)
      end

      def refine_culmination(tt, hour_angle, tolerance)
        rate = SIDEREAL_RATE
        previous = nil

        MAX_ITERATIONS.times do
          residual = wrap(hour_angle_at(tt) - hour_angle)
          return tt if residual.abs < tolerance

          if previous
            measured_rate =
              wrap(residual - previous[:residual]) / (tt - previous[:tt])
            rate = measured_rate if measured_rate.positive?
          end

          previous = {tt: tt, residual: residual}
          tt -= residual / rate
        end

        tt
      end

      def segment_crossings(first, last, target)
        low = [first.tt, @start_tt].max
        high = [last.tt, @end_tt].min
        return [] unless low < high

        f_first = altitude_at(first.tt) - target
        f_last = altitude_at(last.tt) - target

        if [f_first.abs, f_last.abs].min <= GRAZING_MARGIN
          return scan(low, high, target, grazing: true)
        end

        f_low = (low == first.tt) ? f_first : altitude_at(low) - target
        f_high = (high == last.tt) ? f_last : altitude_at(high) - target
        return [] if f_low.negative? == f_high.negative?

        tt = solve(Segment.new(
          first, sample_at(first.tt), last, sample_at(last.tt)
        ), low, f_low, high, target)
        return scan(low, high, target, grazing: false) unless tt

        [Crossing.new(tt, f_low.negative? ? :rising : :setting, false)]
      end

      # Between two consecutive culminations the hour angle goes through
      # exactly half a turn, and the declination moves from its value at one
      # to its value at the other. That gives the rates of both over the
      # segment, which a sidereal day and a fixed declination only approximate:
      # the Sun's right ascension drifts by a degree per day and the Moon's by
      # thirteen.
      class Segment
        attr_reader :hour_angle_rate, :declination_rate

        def initialize(first, first_sample, last, last_sample)
          @first = first
          @first_sample = first_sample
          span = last.tt - first.tt
          consecutive = first.kind != last.kind && span.positive?

          @hour_angle_rate = consecutive ? Math::PI / span : SIDEREAL_RATE
          @declination_rate = if consecutive
            (last_sample.declination - first_sample.declination) / span
          else
            0.0
          end
          @first_hour_angle =
            (first.kind == AltitudeExtreme::UPPER_CULMINATION) ? 0.0 : Math::PI
          @consecutive = consecutive
        end

        def consecutive? = @consecutive

        def declination_at(tt)
          @first_sample.declination + @declination_rate * (tt - @first.tt)
        end

        def time_at_hour_angle(hour_angle)
          @first.tt + (hour_angle - @first_hour_angle) / @hour_angle_rate
        end
      end

      def solve(segment, low, f_low, high, target)
        x = initial_guess(segment, low, high, f_low, target)
        previous = nil

        MAX_ITERATIONS.times do
          f_x = altitude_at(x) - target
          return x if f_x.abs < ALTITUDE_TOLERANCE

          if f_x.negative? == f_low.negative?
            low = x
            f_low = f_x
          else
            high = x
          end

          slope = if previous
            (f_x - previous[:f]) / (x - previous[:tt])
          else
            analytic_slope(x, segment)
          end
          previous = {tt: x, f: f_x}

          step = x - f_x / slope
          within = step > low && step < high
          return step if within && f_x.abs < NEWTON_ACCEPT && segment.consecutive?

          x = within ? step : (low + high) / 2
        end

        nil
      end

      def initial_guess(segment, low, high, f_low, target)
        guess = if segment.consecutive?
          guess_from_segment(segment, f_low, target, low)
        else
          guess_from_sample(low, f_low, target)
        end

        (guess > low && guess < high) ? guess : (low + high) / 2
      end

      def guess_from_segment(segment, f_low, target, low)
        # The declination at the crossing depends on when it happens, so the
        # time is refined once from the first estimate.
        tt = low
        2.times do
          declination = segment.declination_at(tt)
          half_arc = half_arc_for(target, declination)
          needed = f_low.negative? ? TAU - half_arc : half_arc
          tt = segment.time_at_hour_angle(needed)
        end
        tt
      end

      def guess_from_sample(low, f_low, target)
        sample = sample_at(low)
        half_arc = half_arc_for(target, sample.declination)
        needed = f_low.negative? ? TAU - half_arc : half_arc

        low + ((needed - sample.hour_angle) % TAU) / SIDEREAL_RATE
      end

      def half_arc_for(target, declination)
        latitude = @observer.latitude
        ratio = (Math.sin(target) - latitude.sin * Math.sin(declination)) /
          (latitude.cos * Math.cos(declination))

        Math.acos(ratio.clamp(-1.0, 1.0))
      end

      def analytic_slope(tt, segment)
        sample = sample_at(tt)
        latitude = @observer.latitude
        declination = sample.declination
        cos_hour_angle = Math.cos(sample.hour_angle)

        rate_of_sine =
          -latitude.cos * Math.cos(declination) * Math.sin(sample.hour_angle) *
          segment.hour_angle_rate +
          (latitude.sin * Math.cos(declination) -
            latitude.cos * Math.sin(declination) * cos_hour_angle) *
          segment.declination_rate

        rate_of_sine / Math.cos(sample.altitude)
      end

      def scan(first_tt, last_tt, target, grazing:)
        finder = RootFinder.new(
          value_at: ->(tt) { altitude_at(tt) - target },
          period: 1.0,
          samples_per_period: FALLBACK_SAMPLES_PER_DAY
        )

        finder.roots(first_tt, last_tt).map do |tt|
          rising = altitude_at(tt + DIRECTION_PROBE_IN_DAYS) >
            altitude_at(tt - DIRECTION_PROBE_IN_DAYS)
          Crossing.new(tt, rising ? :rising : :setting, grazing)
        end
      end

      def remove_duplicates(crossings)
        crossings.each_with_object([]) do |crossing, kept|
          duplicate = kept.last &&
            (crossing.tt - kept.last.tt) < DUPLICATE_THRESHOLD_IN_DAYS
          kept << crossing unless duplicate
        end
      end

      def build_crossing(crossing)
        AltitudeCrossing.new(
          instant: Instant.from_terrestrial_time(crossing.tt),
          direction: crossing.direction,
          grazing: crossing.grazing
        )
      end
    end
    private_constant :Search
  end
end
