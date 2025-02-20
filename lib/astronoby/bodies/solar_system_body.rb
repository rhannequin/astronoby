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

    attr_reader :geometric, :astrometric, :instant

    def self.geometric(ephem:, instant:)
      compute_geometric(ephem: ephem, instant: instant)
    end

    def self.compute_geometric(ephem:, instant:)
      segments = ephemeris_segments
      segment1 = segments[0]
      segment2 = segments[1] if segments.size == 2

      state1 = ephem[*segment1]
        .compute_and_differentiate(instant.terrestrial_time)

      if segment2
        state2 = ephem[*segment2]
          .compute_and_differentiate(instant.terrestrial_time)
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

    def self.ephemeris_segments
      raise NotImplementedError
    end

    def initialize(ephem:, instant:)
      @instant = instant
      @geometric = compute_geometric(ephem)
      @astrometric = compute_astrometric(ephem)
    end

    private

    def compute_geometric(ephem)
      self.class.compute_geometric(ephem: ephem, instant: @instant)
    end

    def compute_astrometric(ephem)
      Astrometric.build_from_geometric(
        ephem: ephem,
        instant: @instant,
        target_geometric: @geometric,
        target_body: self
      )
    end
  end
end
