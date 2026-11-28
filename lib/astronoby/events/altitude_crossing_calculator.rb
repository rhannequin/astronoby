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

    ALTITUDE_TOLERANCE = Angle.from_degrees(1e-5).radians
    # A Float Julian Date resolves about 47 µs, or 3.4e-9 rad of hour angle,
    # so a tighter tolerance could never be met.
    HOUR_ANGLE_TOLERANCE = 1e-8
    # The ends of a segment only have to be close enough to the culminations
    # for the altitude there to be within GRAZING_MARGIN of the extremum, which
    # a hundred microradians of hour angle is, except for a body passing within
    # a few thousandths of a degree of the zenith.
    SEGMENT_HOUR_ANGLE_TOLERANCE = 1e-4
    CULMINATION_ESTIMATE_MARGIN_IN_DAYS = 1.0 / 96
    CULMINATION_ACCEPT = 2e-3
    MEASURED_CULMINATION_ACCEPT = 5e-3
    EXTRAPOLATION_MARGIN = Angle.from_degrees(1.25).radians
    MIN_NEIGHBOUR_SPAN_IN_DAYS = 1e-7
    SECANT_ACCEPT = 1e-4
    BOUND_LEAD = 1.05
    BOUND_MARGIN_IN_DAYS = 0.01
    GRAZING_MARGIN = Angle.from_degrees(0.05).radians
    # A Newton step from an altitude this close to the target lands within
    # {ALTITUDE_TOLERANCE} of it, for a slope that is off by up to 2%, so the
    # step is returned without evaluating the body there.
    NEWTON_ACCEPT = Angle.from_degrees(5e-4).radians
    SECANT_STEP_ACCEPT_IN_DAYS = 2.0 / Constants::SECONDS_PER_DAY
    SECANT_SPAN_IN_DAYS = 120.0 / Constants::SECONDS_PER_DAY
    MAX_ITERATIONS = 30

    FALLBACK_SAMPLES_PER_DAY = 288
    DIRECTION_PROBE_IN_DAYS = 60.0 / Constants::SECONDS_PER_DAY
    DUPLICATE_THRESHOLD_IN_DAYS = 1e-6

    Sample = Struct.new(:hour_angle, :declination, :altitude, :limb)
    Culmination = Struct.new(:kind, :tt, :sample, :probes)
    COVERAGE_EDGE = :coverage_edge
    Crossing = Struct.new(:tt, :direction, :grazing)

    # @param body [Class, Object] celestial body to track
    # @param observer [Astronoby::Observer] observer location
    # @param ephem [::Ephem::SPK, nil] ephemeris data source
    # @param refraction [Boolean] whether to apply atmospheric refraction to
    #   the altitude, false by default as in the twilight convention
    # @param reference [Symbol] the point of the body that reaches the target:
    #   +:center+, +:upper_limb+ or +:lower_limb+, the limbs using the body's
    #   semi-diameter as seen by the observer
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

    # @deprecated Use {Astronoby::LocalSky#crossings} instead
    # @param start_time [Time, Astronoby::Instant] start of the window
    # @param end_time [Time, Astronoby::Instant] end of the window
    # @param altitude [Astronoby::Angle] the altitude to reach, positive or
    #   negative
    # @return [Array<Astronoby::AltitudeCrossing>] the crossings in the window,
    #   sorted by time
    def crossings_between(start_time, end_time, altitude:)
      warn_deprecated(:crossings_between, "sky.over(observer).crossings")
      search_between(start_time, end_time).crossings([altitude]).first
    end

    # Same as {#crossings_between} for several altitudes at once, sharing the
    # culminations and the evaluated positions between them.
    #
    # @deprecated Use {Astronoby::LocalSky#crossings} instead
    # @param start_time [Time, Astronoby::Instant] start of the window
    # @param end_time [Time, Astronoby::Instant] end of the window
    # @param altitudes [Array<Astronoby::Angle>] the altitudes to reach
    # @return [Array<Array<Astronoby::AltitudeCrossing>>] the crossings of each
    #   altitude, in the order of +altitudes+
    def multiple_crossings_between(start_time, end_time, altitudes:)
      warn_deprecated(
        :multiple_crossings_between,
        "sky.over(observer).crossings"
      )
      search_between(start_time, end_time).crossings(altitudes)
    end

    # @deprecated Use {Astronoby::LocalSky#crossings} instead
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
      warn_deprecated(:crossing_on, "sky.over(observer).crossings")

      start_time = Time.new(date.year, date.month, date.day, 0, 0, 0, utc_offset)
      following = date.next_day
      end_time = Time.new(
        following.year, following.month, following.day, 0, 0, 0, utc_offset
      )

      search_between(start_time, end_time)
        .crossings([altitude])
        .first
        .find do |crossing|
          crossing.direction == direction &&
            crossing.instant.to_time < end_time
        end
    end

    # @deprecated Use {Astronoby::LocalSky#culminations} instead
    # @param start_time [Time, Astronoby::Instant] start of the window
    # @param end_time [Time, Astronoby::Instant] end of the window
    # @return [Array<Astronoby::AltitudeExtreme>] the upper and lower
    #   culminations in the window, sorted by time, with the altitude of the
    #   reference point at each
    def extremes_between(start_time, end_time)
      warn_deprecated(:extremes_between, "sky.over(observer).culminations")
      search_between(start_time, end_time).extremes
    end

    # @api private
    def search_between(start_time, end_time)
      start_instant = Instant.from(start_time)
      end_instant = Instant.from(end_time)
      if end_instant < start_instant
        raise IncompatibleArgumentsError,
          "The end of the window must not be before its start"
      end

      Search.new(
        body: @body,
        observer: @observer,
        ephem: @ephem,
        refraction: @refraction,
        reference: @reference,
        start_tt: start_instant.tt.to_f,
        end_tt: end_instant.tt.to_f,
        coverage: @ephem.respond_to?(:coverage) ? @ephem.coverage : nil
      )
    end

    private

    def warn_deprecated(method_name, replacement)
      Deprecation.warn(self.class, method_name, uplevel: 2) do
        ["Astronoby::AltitudeCrossingCalculator##{method_name}", replacement]
      end
    end

    class Search
      def initialize(
        body:,
        observer:,
        ephem:,
        refraction:,
        reference:,
        start_tt:,
        end_tt:,
        coverage: nil
      )
        @body = body
        @observer = observer
        @ephem = ephem
        @refraction = refraction
        @reference = reference
        @start_tt = start_tt
        @end_tt = end_tt
        @coverage = coverage
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

      def transits
        culminations(
          @start_tt,
          @end_tt,
          HOUR_ANGLE_TOLERANCE,
          kinds: [AltitudeExtreme::UPPER_CULMINATION]
        ).map { |culmination| Instant.from_terrestrial_time(culmination.tt) }
      end

      def horizon_events(altitude, first_tt, last_tt, sides, edges: false)
        ensure_start_covered
        target = altitude.radians
        before_coverage = first_tt < coverage_first
        after_coverage = last_tt > coverage_last
        first_tt = [first_tt, coverage_first].max
        last_tt = [last_tt, coverage_last].min
        return [] unless first_tt < last_tt

        transits = culminations(
          first_tt,
          last_tt,
          HOUR_ANGLE_TOLERANCE,
          kinds: [AltitudeExtreme::UPPER_CULMINATION]
        )
        events = transits.map do |transit|
          rising = side_crossing(transit, target, :rising) if sides.include?(:rising)
          setting = side_crossing(transit, target, :setting) if sides.include?(:setting)
          [rising&.tt, transit.tt, setting&.tt]
        end

        if edges && before_coverage && sides.include?(:setting)
          setting = edge_setting(transits.first&.tt || last_tt, target)
          events.unshift([nil, nil, setting.tt]) if setting
        end
        if edges && after_coverage && sides.include?(:rising)
          rising = edge_rising(transits.last&.tt || first_tt, target)
          events.push([rising.tt, nil, nil]) if rising
        end

        events.map do |tts|
          tts.map { |tt| tt && Instant.from_terrestrial_time(tt) }
        end
      end

      def extremes
        culminations(@start_tt, @end_tt, HOUR_ANGLE_TOLERANCE).map do |culmination|
          AltitudeExtreme.new(
            kind: culmination.kind,
            instant: Instant.from_terrestrial_time(culmination.tt),
            altitude: Angle.from_radians(altitude_at(culmination.tt)),
            refracted: @refraction,
            observer: @observer
          )
        end
      end

      private

      def sample_at(tt)
        @samples[tt] ||= begin
          instant = Instant.from_terrestrial_time(tt)
          body = Sky::Snapshot.new(ephem: @ephem, instant: instant).body(@body)
          topocentric = body.observed_by(@observer)
          equatorial = topocentric.equatorial
          hour_angle = equatorial.compute_hour_angle(
            time: instant.to_time,
            longitude: @observer.longitude
          )
          declination = equatorial.declination
          limb = limb_offset(body, topocentric.distance)

          Sample.new(
            hour_angle.radians,
            declination.radians,
            reference_altitude(declination, hour_angle, limb),
            limb
          )
        end
      end

      def reference_altitude(declination, hour_angle, limb)
        latitude = @observer.latitude
        sin_altitude = latitude.sin * declination.sin +
          latitude.cos * declination.cos * hour_angle.cos
        altitude = Angle.asin(sin_altitude.clamp(-1.0, 1.0)) +
          Angle.from_radians(limb)

        if @refraction
          altitude += Refraction.angle(altitude: altitude, observer: @observer)
        end

        altitude.radians
      end

      def limb_offset(body, distance)
        return 0.0 if @reference == :center

        semidiameter = Math.asin(body.class::EQUATORIAL_RADIUS.m / distance.m)
        (@reference == :upper_limb) ? semidiameter : -semidiameter
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
        bounds.each_cons(2).select do |first, last|
          last.tt >= @start_tt && first.tt <= @end_tt
        end
      end

      def bounds
        @bounds ||= begin
          first_tt, last_tt = @coverage || [-Float::INFINITY, Float::INFINITY]
          start_hour_angle = hour_angle_at(@start_tt)
          since = (start_hour_angle % Math::PI) / SIDEREAL_RATE
          from_tt = @start_tt - since * BOUND_LEAD - BOUND_MARGIN_IN_DAYS
          found = []
          if from_tt < first_tt + BOUND_MARGIN_IN_DAYS
            from_tt = [first_tt, @start_tt].min
            found << Culmination.new(COVERAGE_EDGE, from_tt, sample_at(from_tt))
          end

          rate = nil
          if from_tt < @start_tt
            turned = (start_hour_angle - hour_angle_at(from_tt)) % TAU
            rate = turned / (@start_tt - from_tt) if turned.positive?
          end

          found.concat(culminations(
            from_tt,
            @end_tt,
            SEGMENT_HOUR_ANGLE_TOLERANCE,
            accept: true,
            beyond: true,
            limit_tt: last_tt - BOUND_MARGIN_IN_DAYS,
            measured_rate: rate
          ))
          if found.empty? || found.last.tt <= @end_tt
            edge_tt = [last_tt, @end_tt].max
            found << Culmination.new(COVERAGE_EDGE, edge_tt, sample_at(edge_tt))
          end
          found
        end
      end

      def culminations(
        start_tt,
        end_tt,
        tolerance,
        kinds: [AltitudeExtreme::UPPER_CULMINATION, AltitudeExtreme::LOWER_CULMINATION],
        accept: false,
        beyond: false,
        limit_tt: Float::INFINITY,
        measured_rate: nil
      )
        step = (kinds.size == 2) ? Math::PI : TAU
        offset = (kinds == [AltitudeExtreme::LOWER_CULMINATION]) ? Math::PI : 0.0
        start_hour_angle = hour_angle_at(start_tt)
        angle = offset + ((start_hour_angle - offset) / step).ceil * step
        rate = measured_rate || SIDEREAL_RATE
        measured = !measured_rate.nil?
        tt = start_tt + (angle - start_hour_angle) / rate
        previous = nil
        found = []

        loop do
          break if tt > limit_tt
          break if !beyond && tt > end_tt + CULMINATION_ESTIMATE_MARGIN_IN_DAYS

          refined = refine_culmination(
            tt, angle % TAU, tolerance,
            accept: accept && (measured ? MEASURED_CULMINATION_ACCEPT : CULMINATION_ACCEPT),
            rate: rate
          )
          break unless refined

          tt, sample, probes = refined
          sample = extreme_sample(sample, angle % TAU) if accept
          kind = (angle / Math::PI).round.even? ?
            AltitudeExtreme::UPPER_CULMINATION :
            AltitudeExtreme::LOWER_CULMINATION
          if (beyond && found.empty?) || (tt >= start_tt && (beyond || tt <= end_tt))
            found << Culmination.new(kind, tt, sample, probes)
          end
          break if beyond && tt > end_tt

          if previous && tt > previous
            rate = step / (tt - previous)
            measured = true
          end
          previous = tt
          angle += step
          tt += step / rate
        end

        found
      end

      def refine_culmination(
        tt,
        hour_angle,
        tolerance,
        accept: false,
        rate: SIDEREAL_RATE
      )
        previous = nil

        MAX_ITERATIONS.times do
          return unless covered?(tt)

          sample = sample_at(tt)
          residual = wrap(sample.hour_angle - hour_angle)
          probes = previous && [[previous[:tt], previous[:sample]], [tt, sample]]
          return [tt, sample, probes] if residual.abs < tolerance

          secant = false
          if previous
            measured_rate =
              wrap(residual - previous[:residual]) / (tt - previous[:tt])
            if measured_rate.positive?
              rate = measured_rate
              secant = true
            end
          end

          step = residual / rate
          return [tt - step, sample, probes] if accept && residual.abs < accept
          return [tt - step, sample, probes] if secant && residual.abs < SECANT_ACCEPT

          previous = {tt: tt, residual: residual, sample: sample}
          tt -= step
        end

        [tt, sample_at(tt)] if covered?(tt)
      end

      def covered?(tt)
        tt.between?(coverage_first, coverage_last)
      end

      def ensure_start_covered
        return if @start_tt >= coverage_first

        raise ::Ephem::OutOfRangeError.new(
          "The ephemeris starts after " \
            "#{Instant.from_terrestrial_time(@start_tt).to_time}",
          @start_tt
        )
      end

      def extreme_sample(sample, hour_angle)
        altitude = geometric_altitude(sample.declination, hour_angle) + sample.limb
        if @refraction
          altitude += Refraction
            .angle(altitude: Angle.from_radians(altitude), observer: @observer)
            .radians
        end

        Sample.new(hour_angle, sample.declination, altitude, sample.limb)
      end

      def edge_rising(after_tt, target)
        lower = culminations(
          after_tt,
          coverage_last,
          SEGMENT_HOUR_ANGLE_TOLERANCE,
          kinds: [AltitudeExtreme::LOWER_CULMINATION],
          accept: true
        ).last
        return unless lower

        edge = Culmination.new(COVERAGE_EDGE, coverage_last, sample_at(coverage_last))
        segment_crossings(
          lower, edge, target,
          direction: :rising, low: lower.tt, high: edge.tt
        ).last
      end

      def edge_setting(before_tt, target)
        lower = culminations(
          coverage_first,
          before_tt,
          SEGMENT_HOUR_ANGLE_TOLERANCE,
          kinds: [AltitudeExtreme::LOWER_CULMINATION],
          accept: true
        ).first
        return unless lower

        edge = Culmination.new(COVERAGE_EDGE, coverage_first, sample_at(coverage_first))
        segment_crossings(
          edge, lower, target,
          direction: :setting, low: edge.tt, high: lower.tt
        ).first
      end

      def side_crossing(transit, target, side)
        estimate = extrapolated_lower(transit, side)
        return exact_side_crossing(transit, target, side) unless estimate

        lower_tt, lower_sample = estimate
        f_transit = transit.sample.altitude - target
        f_lower = lower_sample.altitude - target
        if f_transit.abs <= GRAZING_MARGIN || f_lower.abs <= EXTRAPOLATION_MARGIN
          return exact_side_crossing(transit, target, side)
        end
        return if f_transit.negative? || f_lower.positive?

        lower = Culmination.new(AltitudeExtreme::LOWER_CULMINATION, lower_tt, lower_sample)
        tt = if side == :rising
          solve(
            Segment.new(lower, lower_sample, transit, transit.sample),
            lower_tt, f_lower, transit.tt, target
          )
        else
          solve(
            Segment.new(transit, transit.sample, lower, lower_sample),
            transit.tt, f_transit, lower_tt, target
          )
        end
        return exact_side_crossing(transit, target, side) unless tt

        Crossing.new(tt, side, false)
      end

      def extrapolated_lower(transit, side)
        return if @refraction || transit.probes.nil?

        (neighbour_tt, neighbour), (sample_tt, sample) = transit.probes
        span = sample_tt - neighbour_tt
        return if span.abs < MIN_NEIGHBOUR_SPAN_IN_DAYS

        rate = wrap(sample.hour_angle - neighbour.hour_angle) / span
        return unless rate.positive?

        offset = ((side == :rising) ? -Math::PI : Math::PI) / rate
        lower_tt = transit.tt + offset
        return unless lower_tt.between?(coverage_first, coverage_last)

        declination = sample.declination +
          (sample.declination - neighbour.declination) / span *
            (lower_tt - sample_tt)
        altitude = geometric_altitude(declination, Math::PI) + sample.limb

        [lower_tt, Sample.new(Math::PI, declination, altitude, sample.limb)]
      end

      def exact_side_crossing(transit, target, side)
        direction = (side == :rising) ? -1 : 1
        estimate = transit.tt + direction * Math::PI / SIDEREAL_RATE
        edge = (side == :rising) ? coverage_first : coverage_last
        refined = refine_culmination(
          estimate, Math::PI, SEGMENT_HOUR_ANGLE_TOLERANCE,
          accept: CULMINATION_ACCEPT
        )
        lower = if refined
          tt, sample = refined
          Culmination.new(
            AltitudeExtreme::LOWER_CULMINATION, tt, extreme_sample(sample, Math::PI)
          )
        else
          Culmination.new(COVERAGE_EDGE, edge, sample_at(edge))
        end

        if side == :rising
          segment_crossings(
            lower, transit, target,
            direction: :rising, low: lower.tt, high: transit.tt
          ).last
        else
          segment_crossings(
            transit, lower, target,
            direction: :setting, low: transit.tt, high: lower.tt
          ).first
        end
      end

      def geometric_altitude(declination, hour_angle)
        latitude = @observer.latitude
        Math.asin(
          (latitude.sin * Math.sin(declination) +
            latitude.cos * Math.cos(declination) * Math.cos(hour_angle))
            .clamp(-1.0, 1.0)
        )
      end

      def coverage_first
        @coverage ? @coverage.first : -Float::INFINITY
      end

      def coverage_last
        @coverage ? @coverage.last : Float::INFINITY
      end

      def segment_crossings(
        first,
        last,
        target,
        direction: nil,
        low: [first.tt, @start_tt].max,
        high: [last.tt, @end_tt].min
      )
        return [] unless low < high

        f_first = first.sample.altitude - target
        f_last = last.sample.altitude - target

        if [f_first.abs, f_last.abs].min <= GRAZING_MARGIN
          return of_direction(scan(low, high, target, grazing: true), direction)
        end

        f_low = (low == first.tt) ? f_first : altitude_at(low) - target
        f_high = (high == last.tt) ? f_last : altitude_at(high) - target
        return [] if f_low.negative? == f_high.negative?

        found = f_low.negative? ? :rising : :setting
        return [] if direction && direction != found

        tt = solve(
          Segment.new(first, first.sample, last, last.sample),
          low, f_low, high, target
        )
        unless tt
          return of_direction(scan(low, high, target, grazing: false), direction)
        end

        [Crossing.new(tt, found, false)]
      end

      def of_direction(crossings, direction)
        return crossings unless direction

        crossings.select { |crossing| crossing.direction == direction }
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
          consecutive = first.kind != last.kind && span.positive? &&
            first.kind != COVERAGE_EDGE && last.kind != COVERAGE_EDGE

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

        def limb = @first_sample.limb

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

          secant = previous && (x - previous[:tt]).abs < SECANT_SPAN_IN_DAYS
          slope = if previous
            (f_x - previous[:f]) / (x - previous[:tt])
          else
            analytic_slope(x, segment)
          end
          previous = {tt: x, f: f_x}

          step = x - f_x / slope
          within = step > low && step < high
          return step if within && f_x.abs < NEWTON_ACCEPT && segment.consecutive?
          return step if within && secant && (step - x).abs < SECANT_STEP_ACCEPT_IN_DAYS

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
          half_arc = half_arc_for(target - segment.limb, declination)
          needed = f_low.negative? ? TAU - half_arc : half_arc
          tt = segment.time_at_hour_angle(needed)
        end
        tt
      end

      def guess_from_sample(low, f_low, target)
        sample = sample_at(low)
        half_arc = half_arc_for(target - sample.limb, sample.declination)
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
          after = [tt + DIRECTION_PROBE_IN_DAYS, coverage_last].min
          before = [tt - DIRECTION_PROBE_IN_DAYS, coverage_first].max
          rising = altitude_at(after) > altitude_at(before)
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
