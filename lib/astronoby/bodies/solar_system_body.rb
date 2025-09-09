# frozen_string_literal: true

module Astronoby
  class SolarSystemBody
    SOLAR_SYSTEM_BARYCENTER = 0
    SUN = 10
    MERCURY_BARYCENTER = 1
    MERCURY = 199
    VENUS_BARYCENTER = 2
    VENUS = 299
    EARTH_MOON_BARYCENTER = 3
    EARTH = 399
    MOON = 301
    MARS_BARYCENTER = 4
    JUPITER_BARYCENTER = 5
    SATURN_BARYCENTER = 6
    URANUS_BARYCENTER = 7
    NEPTUNE_BARYCENTER = 8

    attr_reader :geometric, :instant

    def self.geometric(ephem:, instant:)
      compute_geometric(ephem: ephem, instant: instant)
    end

    def self.compute_geometric(ephem:, instant:)
      segments = ephemeris_segments(ephem.type)
      segment1 = segments[0]
      segment2 = segments[1] if segments.size == 2
      cache_key = CacheKey.generate(:geometric, instant, segment1, segment2)

      Astronoby.cache.fetch(cache_key) do
        state1 = ephem[*segment1].state_at(instant.tt)

        if segment2
          state2 = ephem[*segment2].state_at(instant.tt)
          position = state1.position + state2.position
          velocity = state1.velocity + state2.velocity
        else
          position = state1.position
          velocity = state1.velocity
        end

        position_vector = Vector[
          Distance.from_kilometers(position.x),
          Distance.from_kilometers(position.y),
          Distance.from_kilometers(position.z)
        ]

        velocity_vector = Vector[
          Velocity.from_kilometers_per_day(velocity.x),
          Velocity.from_kilometers_per_day(velocity.y),
          Velocity.from_kilometers_per_day(velocity.z)
        ]

        Geometric.new(
          position: position_vector,
          velocity: velocity_vector,
          instant: instant,
          target_body: self
        )
      end
    end

    def self.ephemeris_segments(_ephem_source)
      raise NotImplementedError
    end

    def self.absolute_magnitude
      nil
    end

    def initialize(ephem:, instant:)
      @instant = instant
      @geometric = compute_geometric(ephem)
      @earth_geometric = Earth.geometric(ephem: ephem, instant: instant)
      @light_time_corrected_position,
        @light_time_corrected_velocity =
        Correction::LightTimeDelay.compute(
          center: @earth_geometric,
          target: @geometric,
          ephem: ephem
        )
      compute_sun(ephem) if requires_sun_data?
    end

    def astrometric
      @astrometric ||= Astrometric.build_from_geometric(
        instant: @instant,
        earth_geometric: @earth_geometric,
        light_time_corrected_position: @light_time_corrected_position,
        light_time_corrected_velocity: @light_time_corrected_velocity,
        target_body: self
      )
    end

    def mean_of_date
      @mean_of_date ||= MeanOfDate.build_from_geometric(
        instant: @instant,
        target_geometric: @geometric,
        earth_geometric: @earth_geometric,
        target_body: self
      )
    end

    def apparent
      @apparent ||= Apparent.build_from_astrometric(
        instant: @instant,
        target_astrometric: astrometric,
        earth_geometric: @earth_geometric,
        target_body: self
      )
    end

    def observed_by(observer)
      Topocentric.build_from_apparent(
        apparent: apparent,
        observer: observer,
        instant: @instant,
        target_body: self
      )
    end

    # Returns the constellation of the body
    # @return [Astronoby::Constellation, nil]
    def constellation
      @constellation ||= Constellations::Finder.find(
        Precession.for_equatorial_coordinates(
          coordinates: astrometric.equatorial,
          epoch: JulianDate::B1875
        )
      )
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk
    # @return [Astronoby::Angle, nil] Phase angle of the body
    def phase_angle
      return unless @sun

      @phase_angle ||= begin
        geocentric_elongation = Angle.acos(
          @sun.apparent.equatorial.declination.sin *
          apparent.equatorial.declination.sin +
          @sun.apparent.equatorial.declination.cos *
          apparent.equatorial.declination.cos *
          (
            @sun.apparent.equatorial.right_ascension -
              apparent.equatorial.right_ascension
          ).cos
        )

        term1 = @sun.astrometric.distance.km * geocentric_elongation.sin
        term2 = astrometric.distance.km -
          @sun.astrometric.distance.km * geocentric_elongation.cos
        angle = Angle.atan(term1 / term2)
        Astronoby::Util::Trigonometry
          .adjustement_for_arctangent(term1, term2, angle)
      end
    end

    # Fraction between 0 and 1 of the body's disk that is illuminated.
    # @return [Float, nil] Body's illuminated fraction, between 0 and 1.
    def illuminated_fraction
      return unless phase_angle

      @illuminated_fraction ||= (1 + phase_angle.cos) / 2.0
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk
    # Apparent magnitude of the body, as seen from Earth.
    # @return [Float, nil] Apparent magnitude of the body.
    def apparent_magnitude
      return unless self.class.absolute_magnitude

      @apparent_magnitude ||= begin
        body_sun_distance =
          (astrometric.position - @sun.astrometric.position).magnitude
        self.class.absolute_magnitude +
          5 * Math.log10(body_sun_distance.au * astrometric.distance.au) +
          magnitude_correction_term
      end
    end

    # Angular diameter of the body, as seen from Earth. Based on the apparent
    #   position of the body.
    # @return [Astronoby::Angle] Angular diameter of the body
    def angular_diameter
      @angular_radius ||= begin
        return if apparent.position.zero?

        Angle.from_radians(
          Math.asin(self.class::EQUATORIAL_RADIUS.m / apparent.distance.m) * 2
        )
      end
    end

    # @return [Boolean] True if the body is approaching the primary
    #   body (Sun), false otherwise.
    def approaching_primary?
      relative_position = (geometric.position - @sun.geometric.position)
        .map(&:m)
      relative_velocity = (geometric.velocity - @sun.geometric.velocity)
        .map(&:kmps)
      radial_velocity_component = Astronoby::Util::Maths
        .dot_product(relative_position, relative_velocity)
      distance = Math.sqrt(
        Astronoby::Util::Maths.dot_product(relative_position, relative_position)
      )
      radial_velocity_component / distance < 0
    end

    # @return [Boolean] True if the body is receding from the primary
    #   body (Sun), false otherwise.
    def receding_from_primary?
      !approaching_primary?
    end

    private

    # By default, Solar System bodies expose attributes that are dependent on
    # the Sun's position, such as phase angle and illuminated fraction.
    # If a body does not require Sun data, it should override this method to
    # return false.
    def requires_sun_data?
      true
    end

    def compute_geometric(ephem)
      self.class.compute_geometric(ephem: ephem, instant: @instant)
    end

    def compute_sun(ephem)
      @sun ||= Sun.new(instant: @instant, ephem: ephem)
    end

    # Source:
    #  Title: Explanatory Supplement to the Astronomical Almanac
    #  Authors: Sean E. Urban and P. Kenneth Seidelmann
    #  Edition: University Science Books
    #  Chapter: 10.3 - Phases and Magnitudes
    def magnitude_correction_term
      -2.5 * Math.log10(illuminated_fraction)
    end
  end
end
