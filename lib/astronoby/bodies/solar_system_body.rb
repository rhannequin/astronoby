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

    attr_reader :instant, :ephem

    def self.at(instant, ephem:)
      new(ephem: ephem, instant: instant)
    end

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

    # @param observer [Astronoby::Observer] Observer for whom to calculate rise,
    #   transit, and set events
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param date [Date] Date for which to calculate rise, transit, and set
    #   events (optional)
    # @param start_time [Time] Start time for rise, transit, and set event
    #   calculation (optional)
    # @param end_time [Time] End time for rise, transit, and set event
    #   calculation (optional)
    # @param utc_offset [String] UTC offset for the given date (e.g., "+02:00")
    # @return [RiseTransitSetEvent, Array<RiseTransitSetEvent>] Rise, transit,
    # and set events for the given date or time range.
    def self.rise_transit_set_events(
      observer:,
      ephem:,
      date: nil,
      start_time: nil,
      end_time: nil,
      utc_offset: 0
    )
      calculator = RiseTransitSetCalculator.new(
        body: self,
        observer: observer,
        ephem: ephem
      )
      if date
        calculator.events_on(date, utc_offset: utc_offset)
      else
        calculator.events_between(start_time, end_time)
      end
    end

    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param instant [Astronoby::Instant] Instant for which to calculate the
    #   phase angle
    def initialize(ephem:, instant:)
      @ephem = ephem
      @instant = instant
    end

    def geometric
      @geometric ||= self.class.compute_geometric(
        ephem: @ephem,
        instant: @instant
      )
    end

    def earth_geometric
      @earth_geometric ||= Earth.geometric(ephem: @ephem, instant: @instant)
    end

    def astrometric
      @astrometric ||= Astrometric.build_from_geometric(
        instant: @instant,
        earth_geometric: earth_geometric,
        light_time_corrected_position: light_time_corrected_position,
        light_time_corrected_velocity: light_time_corrected_velocity,
        target_body: self
      )
    end

    def mean_of_date
      @mean_of_date ||= MeanOfDate.build_from_geometric(
        instant: @instant,
        target_geometric: geometric,
        earth_geometric: earth_geometric,
        target_body: self
      )
    end

    def apparent
      @apparent ||= Apparent.build_from_astrometric(
        instant: @instant,
        target_astrometric: astrometric,
        earth_geometric: earth_geometric,
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
      return unless sun

      @phase_angle ||= begin
        geocentric_elongation = Angle.acos(
          sun.apparent.equatorial.declination.sin *
          apparent.equatorial.declination.sin +
          sun.apparent.equatorial.declination.cos *
          apparent.equatorial.declination.cos *
          (
            sun.apparent.equatorial.right_ascension -
              apparent.equatorial.right_ascension
          ).cos
        )

        term1 = sun.astrometric.distance.km * geocentric_elongation.sin
        term2 = astrometric.distance.km -
          sun.astrometric.distance.km * geocentric_elongation.cos
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
          (astrometric.position - sun.astrometric.position).magnitude
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

    # @return [Boolean] True if the body is approaching its primary
    #   body, false otherwise.
    def approaching_primary?
      relative_position =
        (geometric.position - primary_body_geometric.position).map(&:m)
      relative_velocity =
        (geometric.velocity - primary_body_geometric.velocity).map(&:mps)
      radial_velocity_component = Astronoby::Util::Maths
        .dot_product(relative_position, relative_velocity)
      distance = Math.sqrt(
        Astronoby::Util::Maths.dot_product(relative_position, relative_position)
      )
      radial_velocity_component / distance < 0
    end

    # @return [Boolean] True if the body is receding from its primary
    #   body, false otherwise.
    def receding_from_primary?
      !approaching_primary?
    end

    private

    def sun
      @sun ||= Sun.new(instant: @instant, ephem: @ephem)
    end

    def primary_body_geometric
      sun.geometric
    end

    def light_time_corrected_position
      compute_light_time_correction unless @light_time_corrected_position
      @light_time_corrected_position
    end

    def light_time_corrected_velocity
      compute_light_time_correction unless @light_time_corrected_velocity
      @light_time_corrected_velocity
    end

    def compute_light_time_correction
      @light_time_corrected_position, @light_time_corrected_velocity =
        Correction::LightTimeDelay.compute(
          center: earth_geometric,
          target: geometric,
          ephem: @ephem
        )
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
