# frozen_string_literal: true

module Astronoby
  # Computes lunar eclipses over a time range.
  #
  # A lunar eclipse is a geocentric event, identical for every observer who can
  # see the Moon, so no observer is involved. The geometry is built from the
  # apparent geocentric positions of the Sun and Moon: this matches the standard
  # reduction used by IMCCE, validated against IMCCE (Opale, INPOP19A) where the
  # eclipse kind, greatest eclipse, magnitudes, and contact times all agree to
  # within a second or two.
  #
  # Candidate full moons are seeded analytically from Events::MoonPhases, then
  # refined against the ephemeris: full moons far from a node are skipped, the
  # greatest eclipse is the least distance of the Moon's centre from the shadow
  # axis, and each contact is found by bisecting between greatest eclipse (inside
  # the shadow) and the edge of the search window (outside it).
  #
  # Source:
  #  Title: Explanatory Supplement to the Astronomical Almanac
  #  Authors: Sean E. Urban and P. Kenneth Seidelmann
  #  Chapter: 11 - Eclipses of the Sun and Moon
  class LunarEclipseCalculator
    # Atmospheric enlargement of Earth's shadow (Danjon-style): Earth's radius is
    # enlarged before the shadow cones are built, which propagates into both the
    # umbra and the penumbra. The 1/99 factor is calibrated against IMCCE (which
    # uses the same INPOP19A ephemeris): it reproduces IMCCE's umbra and penumbra
    # angular radii to about 0.1 arcsecond across the 2023-2025 eclipses.
    SHADOW_ENLARGEMENT = 1.0 + 1.0 / 99

    SUN_RADIUS_KM = Sun::EQUATORIAL_RADIUS.km
    MOON_RADIUS_KM = Moon::EQUATORIAL_RADIUS.km
    EARTH_RADIUS_KM =
      Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS / 1000.0

    # Largest distance of the Moon's centre from the shadow axis, in Earth radii,
    # at which any (penumbral) eclipse is still possible is about 1.57. Full moons
    # whose seed already exceeds this margin cannot be eclipses and skip the
    # minimum search entirely.
    MAX_ECLIPSE_GAMMA = 1.8

    # Half-window, in days, for the local greatest-eclipse search around a full
    # moon. A lunar eclipse occurs within minutes of full moon.
    GREATEST_HALF_WINDOW = 0.25

    # Half-window, in days, for the contact search around greatest eclipse. Wide
    # enough to bracket the longest penumbral phase (about 3 hours each side).
    CONTACT_HALF_WINDOW = 0.21

    SEARCH_SAMPLES = 48

    # Bisection tolerance, in days, for a contact time. ~1e-7 day is ~8.6 ms,
    # well below the one-second resolution the contacts are reported at.
    CONTACT_TOLERANCE = 1e-7

    # Geometry of the Sun, Moon and Earth's shadow at one instant, in kilometres
    # in the plane perpendicular to the shadow axis at the Moon's distance.
    class Geometry
      # @return [Float] distance of the Moon's centre from the shadow axis (km)
      attr_reader :axis_distance

      # @return [Float] radius of the umbra at the Moon's distance (km)
      attr_reader :umbra_radius

      # @return [Float] radius of the penumbra at the Moon's distance (km)
      attr_reader :penumbra_radius

      # @return [Float] signed distance from the shadow axis, in Earth radii
      attr_reader :gamma

      def initialize(axis_distance:, umbra_radius:, penumbra_radius:, gamma:)
        @axis_distance = axis_distance
        @umbra_radius = umbra_radius
        @penumbra_radius = penumbra_radius
        @gamma = gamma
        freeze
      end

      def umbral_magnitude
        (umbra_radius + MOON_RADIUS_KM - axis_distance) / (2 * MOON_RADIUS_KM)
      end

      def penumbral_magnitude
        (
          penumbra_radius + MOON_RADIUS_KM - axis_distance
        ) / (2 * MOON_RADIUS_KM)
      end

      def penumbral_contact_value
        axis_distance - (penumbra_radius + MOON_RADIUS_KM)
      end

      def partial_contact_value
        axis_distance - (umbra_radius + MOON_RADIUS_KM)
      end

      def total_contact_value
        axis_distance - (umbra_radius - MOON_RADIUS_KM)
      end
    end

    # @param ephem [::Ephem::SPK] ephemeris data source
    def initialize(ephem:)
      @ephem = ephem
      @geometry_cache = {}
    end

    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @return [Array<Astronoby::LunarEclipse>] eclipses whose greatest instant
    #   lies in the range, sorted by time
    def events_between(start_time, end_time)
      full_moon_seeds(start_time, end_time)
        .filter_map { |seed_jd| eclipse_near(seed_jd) }
        .select do |eclipse|
          eclipse.instant.to_time.between?(start_time, end_time)
        end
    end

    private

    # Full moons in the range, padded by a day so an eclipse near a boundary is
    # not missed. Seeded analytically (Meeus, chapter 49) at no ephemeris cost.
    def full_moon_seeds(start_time, end_time)
      padded_start = start_time - Constants::SECONDS_PER_DAY
      padded_end = end_time + Constants::SECONDS_PER_DAY
      year_months(padded_start, padded_end)
        .flat_map do |year, month|
          Events::MoonPhases.phases_for(year: year, month: month)
        end
        .select { |phase| phase.phase == :full_moon }
        .map(&:time)
        .select { |time| time.between?(padded_start, padded_end) }
        .map { |time| Instant.from_time(time).tt }
    end

    def year_months(from, to)
      cursor = Date.new(from.to_date.year, from.to_date.month, 1)
      last = Date.new(to.to_date.year, to.to_date.month, 1)
      months = []
      while cursor <= last
        months << [cursor.year, cursor.month]
        cursor = cursor.next_month
      end
      months
    end

    # Resolves the eclipse for one full-moon seed, if any.
    def eclipse_near(seed_jd)
      if geometry_at(seed_jd).axis_distance > MAX_ECLIPSE_GAMMA * EARTH_RADIUS_KM
        return nil
      end

      greatest_jd = greatest_eclipse_jd(seed_jd)
      greatest_jd && eclipse_at(greatest_jd)
    ensure
      @geometry_cache.clear
    end

    # Greatest eclipse: the least distance of the Moon's centre from the shadow
    # axis, found by minimising it on a narrow window around the full moon.
    def greatest_eclipse_jd(seed_jd)
      ExtremumFinder
        .new(
          value_at: ->(jd) { geometry_at(jd).axis_distance },
          period: 2 * GREATEST_HALF_WINDOW,
          samples_per_period: SEARCH_SAMPLES
        )
        .extrema(
          seed_jd - GREATEST_HALF_WINDOW,
          seed_jd + GREATEST_HALF_WINDOW,
          type: :minimum
        )
        .min_by { |extremum| extremum[:value] }
        &.fetch(:jd)
    end

    def eclipse_at(greatest_jd)
      geometry = geometry_at(greatest_jd)
      penumbral = phase_for(greatest_jd, &:penumbral_contact_value)
      return nil if penumbral.nil?

      partial = phase_for(greatest_jd, &:partial_contact_value)
      total = phase_for(greatest_jd, &:total_contact_value)

      LunarEclipse.new(
        instant: Instant.from_terrestrial_time(greatest_jd),
        kind: kind_for(partial, total),
        umbral_magnitude: geometry.umbral_magnitude,
        penumbral_magnitude: geometry.penumbral_magnitude,
        gamma: geometry.gamma,
        shadow_axis_distance: Distance.from_kilometers(geometry.axis_distance),
        penumbral: penumbral,
        partial: partial,
        total: total
      )
    end

    def kind_for(partial, total)
      if total
        LunarEclipse::TOTAL
      elsif partial
        LunarEclipse::PARTIAL
      else
        LunarEclipse::PENUMBRAL
      end
    end

    # Builds a phase from a contact function. The phase occurs only when the
    # Moon is inside the boundary at greatest eclipse (contact value negative);
    # each contact is then the single crossing between greatest eclipse and the
    # corresponding edge of the window, found by bisection. This is robust to
    # arbitrarily short phases (a barely-total or grazing eclipse), unlike a
    # fixed-resolution scan that can step over a brief crossing.
    def phase_for(greatest_jd, &contact_value)
      value_at = ->(jd) { contact_value.call(geometry_at(jd)) }
      return nil unless value_at.call(greatest_jd).negative?

      starting = bisect_contact(
        value_at,
        greatest_jd - CONTACT_HALF_WINDOW,
        greatest_jd
      )
      ending = bisect_contact(
        value_at,
        greatest_jd + CONTACT_HALF_WINDOW,
        greatest_jd
      )
      return nil unless starting && ending

      EclipsePhase.new(
        starting_instant: Instant.from_terrestrial_time(starting),
        ending_instant: Instant.from_terrestrial_time(ending)
      )
    end

    # Bisects for the single contact between +outside_jd+ (value positive, the
    # Moon outside the boundary) and +inside_jd+ (value negative, at greatest
    # eclipse). Returns nil if the boundary is not crossed within the window.
    def bisect_contact(value_at, outside_jd, inside_jd)
      return nil unless value_at.call(outside_jd).positive?

      while (inside_jd - outside_jd).abs > CONTACT_TOLERANCE
        midpoint = (outside_jd + inside_jd) / 2.0
        if value_at.call(midpoint).negative?
          inside_jd = midpoint
        else
          outside_jd = midpoint
        end
      end
      (outside_jd + inside_jd) / 2.0
    end

    # Builds the geometry at a Julian Date (TT) from the apparent geocentric
    # positions of the Sun and Moon. Memoised so repeated evaluations during the
    # searches reuse the same computation.
    def geometry_at(jd)
      @geometry_cache[jd] ||= begin
        instant = Instant.from_terrestrial_time(jd)
        moon = Moon.new(ephem: @ephem, instant: instant).apparent
        sun = Sun.new(ephem: @ephem, instant: instant).apparent

        moon_distance = moon.distance.km
        sun_distance = sun.distance.km
        axis_angle = Math::PI - sun.separation_from(moon).radians
        axial_distance = moon_distance * Math.cos(axis_angle)
        perpendicular_distance = moon_distance * Math.sin(axis_angle)

        # Danjon enlargement: enlarge Earth's radius before building the cones.
        earth_radius = EARTH_RADIUS_KM * SHADOW_ENLARGEMENT
        umbra_half_angle_tangent = (SUN_RADIUS_KM - earth_radius) / sun_distance
        penumbra_half_angle_tangent =
          (SUN_RADIUS_KM + earth_radius) / sun_distance
        latitude_sign = moon.ecliptic.latitude.degrees.negative? ? -1 : 1

        Geometry.new(
          axis_distance: perpendicular_distance,
          umbra_radius: earth_radius - axial_distance * umbra_half_angle_tangent,
          penumbra_radius: earth_radius + axial_distance * penumbra_half_angle_tangent,
          gamma: latitude_sign * perpendicular_distance / EARTH_RADIUS_KM
        )
      end
    end
  end
end
