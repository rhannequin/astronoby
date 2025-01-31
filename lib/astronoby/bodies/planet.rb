# frozen_string_literal: true

module Astronoby
  class Planet
    SOLAR_SYSTEM_BARYCENTER = 0
    MERCURY_BARYCENTER = 1
    MERCURY = 199
    VENUS_BARYCENTER = 2
    VENUS = 299
    EARTH_MOON_BARYCENTER = 3
    EARTH = 399
    MARS_BARYCENTER = 4
    JUPITER_BARYCENTER = 5
    SATURN_BARYCENTER = 6
    URANUS_BARYCENTER = 7
    NEPTUNE_BARYCENTER = 8

    attr_reader :barycentric, :instant

    def initialize(ephem:, instant:)
      @instant = instant
      @barycentric = compute_barycentric(ephem: ephem, instant: instant)
    end

    private

    def ephemeris_segments
      raise NotImplementedError
    end

    def compute_barycentric(ephem:, instant:)
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

      Position::Barycentric.new(
        position: position,
        velocity: velocity,
        instant: instant,
        target_body: self.class
      )
    end
  end
end
