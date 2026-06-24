# frozen_string_literal: true

module Astronoby
  # Base class for solar system bodies. Provides the reference frame chain
  # (geometric -> astrometric -> mean-of-date -> apparent -> topocentric)
  # and common observational properties (phase angle, magnitude, etc.).
  class SolarSystemBody
    include Position
    extend Body

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

    # @return [Astronoby::Instant] the time instant
    attr_reader :instant

    # @return [::Ephem::SPK] the ephemeris data source
    attr_reader :ephem

    # @return [Astronoby::Orientation, nil] the orientation kernel, if provided
    attr_reader :orientation

    # Creates a new body instance at the given instant.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param orientation [Astronoby::Orientation, nil] orientation kernel
    # @return [Astronoby::SolarSystemBody] a new body instance
    def self.at(instant, ephem:, orientation: nil)
      new(ephem: ephem, instant: instant, orientation: orientation)
    end

    # Computes the geometric reference frame for this body.
    #
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param instant [Astronoby::Instant] the time instant
    # @return [Astronoby::Geometric] the geometric frame
    def self.geometric(ephem:, instant:)
      compute_geometric(ephem: ephem, instant: instant)
    end

    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param instant [Astronoby::Instant] the time instant
    # @return [Astronoby::Geometric] the geometric frame
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

    # @param _ephem_source [Symbol] the ephemeris source type
    # @return [Array<Array>] ephemeris segment identifiers
    # @raise [NotImplementedError] must be implemented by subclasses
    def self.ephemeris_segments(_ephem_source)
      raise NotImplementedError
    end

    # @return [Float, nil] absolute magnitude of the body
    def self.absolute_magnitude
      nil
    end

    # @return [Boolean] true for an inferior planet (Mercury, Venus)
    def self.inferior_planet?
      false
    end

    # @return [Boolean] true for a superior planet (Mars through Neptune)
    def self.superior_planet?
      false
    end

    # @return [Boolean] true for a planet (excludes the Sun, Earth and Moon)
    def self.planet?
      inferior_planet? || superior_planet?
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
    # @return [Astronoby::RiseTransitSetEvent,
    #   Array<Astronoby::RiseTransitSetEvent>] Rise, transit, and set events for
    #   the given date or time range.
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

    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @param samples_per_period [Integer] number of samples per synodic period
    # @return [Array<Astronoby::Conjunction>] conjunctions with the Sun
    # @raise [Astronoby::UnsupportedEventError] unless the body is a planet
    def self.conjunction_events(
      ephem:,
      start_time:,
      end_time:,
      samples_per_period: 60
    )
      unless planet?
        raise UnsupportedEventError, "#{self} has no conjunctions with the Sun"
      end

      ConjunctionOppositionCalculator.new(
        body: self,
        ephem: ephem,
        samples_per_period: samples_per_period
      ).conjunction_events_between(start_time, end_time)
    end

    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @param samples_per_period [Integer] number of samples per synodic period
    # @return [Array<Astronoby::Opposition>] oppositions with the Sun
    # @raise [Astronoby::UnsupportedEventError] unless the body is a superior
    #   planet
    def self.opposition_events(
      ephem:,
      start_time:,
      end_time:,
      samples_per_period: 60
    )
      unless superior_planet?
        raise UnsupportedEventError, "#{self} has no oppositions with the Sun"
      end

      ConjunctionOppositionCalculator.new(
        body: self,
        ephem: ephem,
        samples_per_period: samples_per_period
      ).opposition_events_between(start_time, end_time)
    end

    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @param samples_per_period [Integer] number of samples per synodic period
    # @return [Array<Astronoby::GreatestElongation>] greatest elongations
    # @raise [Astronoby::UnsupportedEventError] unless the body is an inferior
    #   planet
    def self.greatest_elongation_events(
      ephem:,
      start_time:,
      end_time:,
      samples_per_period: 60
    )
      unless inferior_planet?
        raise UnsupportedEventError,
          "#{self} has no greatest elongations from the Sun"
      end

      GreatestElongationCalculator.new(
        body: self,
        ephem: ephem,
        samples_per_period: samples_per_period
      ).greatest_elongation_events_between(start_time, end_time)
    end

    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param instant [Astronoby::Instant] Instant for which to calculate the
    #   phase angle
    # @param orientation [Astronoby::Orientation, nil] Orientation kernel,
    #   enabling arcsecond-accurate lunar libration and axis position angle
    def initialize(ephem:, instant:, orientation: nil)
      @ephem = ephem
      @instant = instant
      @orientation = orientation
    end

    # @return [Astronoby::Geometric] the geometric reference frame (BCRS)
    def geometric
      @geometric ||= self.class.compute_geometric(
        ephem: @ephem,
        instant: @instant
      )
    end

    # @return [Astronoby::Geometric] Earth's geometric reference frame
    def earth_geometric
      @earth_geometric ||= Earth.geometric(ephem: @ephem, instant: @instant)
    end

    # @return [Astronoby::Astrometric] the astrometric reference frame (GCRS)
    def astrometric
      @astrometric ||= Astrometric.build_from_geometric(
        instant: @instant,
        earth_geometric: earth_geometric,
        light_time_corrected_position: light_time_corrected_position,
        light_time_corrected_velocity: light_time_corrected_velocity,
        target_body: body
      )
    end

    # @return [Astronoby::MeanOfDate] the mean-of-date reference frame
    def mean_of_date
      @mean_of_date ||= MeanOfDate.build_from_geometric(
        instant: @instant,
        target_geometric: geometric,
        earth_geometric: earth_geometric,
        target_body: body
      )
    end

    # @return [Astronoby::Apparent] the apparent reference frame
    def apparent
      @apparent ||= Apparent.build_from_astrometric(
        instant: @instant,
        target_astrometric: astrometric,
        earth_geometric: earth_geometric,
        target_body: body
      )
    end

    # @return [Astronoby::Body] the body definition (the class itself)
    def body
      self.class
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

    # Apparent geocentric Sun-Earth-body angle
    # @return [Astronoby::Angle, nil] Elongation of the body
    def elongation
      return unless sun

      @elongation ||= sun.apparent.separation_from(apparent)
    end

    # @return [Boolean] true when the body is east of the Sun
    def eastern?
      (apparent.ecliptic.longitude - sun.apparent.ecliptic.longitude)
        .sin.positive?
    end

    # @return [Boolean] true when the body is west of the Sun
    def western?
      !eastern?
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
        term1 = sun.astrometric.distance.km * elongation.sin
        term2 = astrometric.distance.km -
          sun.astrometric.distance.km * elongation.cos
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
