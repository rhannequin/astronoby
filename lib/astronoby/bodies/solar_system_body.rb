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

    private

    def compute_geometric(ephem)
      self.class.compute_geometric(ephem: ephem, instant: @instant)
    end
  end
end
