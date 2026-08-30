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
    # Atmospheric enlargement of Earth's shadow (Danjon-style): the shell of
    # atmosphere added to Earth's radius before the shadow cones are built, which
    # propagates into both the umbra and the penumbra. Calibrated against IMCCE,
    # which uses the same INPOP19A ephemeris, over the eclipses from 2026 to
    # 2048. It is well below the textbook values, which put the shell at 75 km
    # (Danjon) or 128 km (Chauvenet).
    SHADOW_ATMOSPHERE_KM = 64.0

    SUN_RADIUS_KM = Sun::EQUATORIAL_RADIUS.km
    EARTH_RADIUS_KM =
      Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS / 1000.0
    MOON_RADIUS_KM = Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

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

    # Which limb of the Moon a phase boundary touches the shadow cone with. The
    # penumbral and partial phases are bounded by external tangencies, where the
    # contact point is on the limb facing the shadow axis; the total phase by
    # internal ones, where it is on the far limb. Greatest eclipse has no
    # contact point, and IMCCE reports the axis-to-Moon direction there.
    EXTERNAL_TANGENCY = :external
    INTERNAL_TANGENCY = :internal
    NO_TANGENCY = :none

    # Geometry of the Sun, Moon and Earth's shadow at one instant, in kilometres
    # in the plane perpendicular to the shadow axis at the Moon's distance.
    class Geometry
      # @return [Float] distance of the Moon's centre from the shadow axis (km)
      attr_reader :axis_distance

      # @return [Float] radius of the umbra at the Moon's distance (km)
      attr_reader :umbra_radius

      # @return [Float] radius of the penumbra at the Moon's distance (km)
      attr_reader :penumbra_radius

      # @return [Boolean] whether the Moon is north of the shadow axis
      attr_reader :north_of_axis

      # @return [Float] position angle of the Moon's centre from the shadow
      #   axis, in radians from celestial north through east
      attr_reader :position_angle

      # @return [Float] geocentric distance of the Moon (km)
      attr_reader :moon_distance

      # @return [Float] x component of the Moon's apparent geocentric unit
      #   vector, in the true equator and equinox of date
      attr_reader :moon_unit_x

      # @return [Float] y component of the Moon's apparent geocentric unit
      #   vector, in the true equator and equinox of date
      attr_reader :moon_unit_y

      # @return [Float] z component of the Moon's apparent geocentric unit
      #   vector, in the true equator and equinox of date
      attr_reader :moon_unit_z

      # @return [Numeric] Julian Date (TT) the geometry was built at, which is
      #   the epoch its equator and equinox are referred to
      attr_reader :epoch

      def initialize(
        axis_distance:,
        umbra_radius:,
        penumbra_radius:,
        north_of_axis:,
        position_angle:,
        moon_distance:,
        moon_unit_x:,
        moon_unit_y:,
        moon_unit_z:,
        epoch:
      )
        @axis_distance = axis_distance
        @umbra_radius = umbra_radius
        @penumbra_radius = penumbra_radius
        @north_of_axis = north_of_axis
        @position_angle = position_angle
        @moon_distance = moon_distance
        @moon_unit_x = moon_unit_x
        @moon_unit_y = moon_unit_y
        @moon_unit_z = moon_unit_z
        @epoch = epoch
        freeze
      end

      def to_lunar_eclipse_geometry(tangency)
        angle = if tangency == EXTERNAL_TANGENCY
          (position_angle + Math::PI) % Constants::RADIANS_PER_CIRCLE
        else
          position_angle
        end

        LunarEclipseGeometry.new(
          axis_distance: Distance.from_kilometers(axis_distance),
          position_angle: Angle.from_radians(angle),
          umbra_radius: Distance.from_kilometers(umbra_radius),
          penumbra_radius: Distance.from_kilometers(penumbra_radius),
          moon_distance: Distance.from_kilometers(moon_distance),
          moon_coordinates: moon_coordinates,
          north_of_axis: north_of_axis
        )
      end

      def moon_coordinates
        Coordinates::Equatorial.new(
          right_ascension: Angle.from_radians(
            Math.atan2(moon_unit_y, moon_unit_x) %
              Constants::RADIANS_PER_CIRCLE
          ),
          declination: Angle.asin(moon_unit_z.clamp(-1.0, 1.0)),
          epoch: epoch
        )
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

    private_constant :Geometry

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
      penumbral = phase_for(
        greatest_jd,
        EXTERNAL_TANGENCY,
        &:penumbral_contact_value
      )
      return nil if penumbral.nil?

      partial = phase_for(greatest_jd, EXTERNAL_TANGENCY, &:partial_contact_value)
      total = phase_for(greatest_jd, INTERNAL_TANGENCY, &:total_contact_value)

      LunarEclipse.new(
        instant: Instant.from_terrestrial_time(greatest_jd),
        kind: kind_for(partial, total),
        geometry: geometry.to_lunar_eclipse_geometry(NO_TANGENCY),
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
    def phase_for(greatest_jd, tangency, &contact_value)
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

      starting_jd, starting_geometry = starting
      ending_jd, ending_geometry = ending

      LunarEclipsePhase.new(
        starting_instant: Instant.from_terrestrial_time(starting_jd),
        ending_instant: Instant.from_terrestrial_time(ending_jd),
        starting_geometry:
          starting_geometry.to_lunar_eclipse_geometry(tangency),
        ending_geometry: ending_geometry.to_lunar_eclipse_geometry(tangency)
      )
    end

    # Bisects for the single contact between +outside_jd+ (value positive, the
    # Moon outside the boundary) and +inside_jd+ (value negative, at greatest
    # eclipse). Returns the contact date, taken as the midpoint of the final
    # bracket, and the geometry already computed at that bracket's inner end, at
    # most 2 ms away. Returns nil if the boundary is not crossed in the window.
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
      [(outside_jd + inside_jd) / 2.0, geometry_at(inside_jd)]
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

        moon_x, moon_y, moon_z =
          moon.position.to_a.map { |component| component.km / moon_distance }
        axis_x, axis_y, axis_z =
          sun.position.to_a.map { |component| -component.km / sun_distance }

        hypotenuse = Math.sqrt(axis_x * axis_x + axis_y * axis_y)
        east_x = -axis_y / hypotenuse
        east_y = axis_x / hypotenuse
        north_x = -axis_z * east_y
        north_y = axis_z * east_x
        north_z = axis_x * east_y - axis_y * east_x

        east = moon_x * east_x + moon_y * east_y
        north = moon_x * north_x + moon_y * north_y + moon_z * north_z
        cosine = moon_x * axis_x + moon_y * axis_y + moon_z * axis_z
        sine = Math.sqrt(east * east + north * north)

        axial_distance = moon_distance * cosine
        perpendicular_distance = moon_distance * sine

        # Danjon enlargement: enlarge Earth's radius before building the cones.
        earth_radius = EARTH_RADIUS_KM + SHADOW_ATMOSPHERE_KM
        umbra_half_angle_tangent = (SUN_RADIUS_KM - earth_radius) / sun_distance
        penumbra_half_angle_tangent =
          (SUN_RADIUS_KM + earth_radius) / sun_distance

        Geometry.new(
          axis_distance: perpendicular_distance,
          umbra_radius: earth_radius - axial_distance * umbra_half_angle_tangent,
          penumbra_radius: earth_radius + axial_distance * penumbra_half_angle_tangent,
          north_of_axis: !north.negative?,
          position_angle: Math.atan2(east, north) % Constants::RADIANS_PER_CIRCLE,
          moon_distance: moon_distance,
          moon_unit_x: moon_x,
          moon_unit_y: moon_y,
          moon_unit_z: moon_z,
          epoch: jd
        )
      end
    end
  end
end
