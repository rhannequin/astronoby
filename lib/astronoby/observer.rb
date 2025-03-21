# frozen_string_literal: true

module Astronoby
  class Observer
    DEFAULT_ELEVATION = Distance.zero
    DEFAULT_TEMPERATURE = 283.15
    PRESSURE_AT_SEA_LEVEL = 1013.25
    PASCAL_PER_MILLIBAR = 0.01
    EARTH_GRAVITATIONAL_ACCELERATION = 9.80665
    MOLAR_MASS_OF_AIR = 0.0289644
    UNIVERSAL_GAS_CONSTANT = 8.31432

    attr_reader :latitude,
      :longitude,
      :elevation,
      :utc_offset,
      :temperature,
      :pressure

    # @param latitude [Angle] geographic latitude of the observer
    # @param longitude [Angle] geographic longitude of the observer
    # @param elevation [Astronoby::Distance] geographic elevation (or altitude)
    #   of the observer above sea level
    # @param utc_offset [Numeric, String] offset from Coordinated Universal Time
    # @param temperature [Numeric] temperature at the observer's location in
    #   kelvins
    # @param pressure [Numeric] atmospheric pressure at the observer's
    #   location in millibars
    def initialize(
      latitude:,
      longitude:,
      elevation: DEFAULT_ELEVATION,
      utc_offset: 0,
      temperature: DEFAULT_TEMPERATURE,
      pressure: nil
    )
      @latitude = latitude
      @longitude = longitude
      @elevation = elevation
      @utc_offset = utc_offset
      @temperature = temperature
      @pressure = pressure || compute_pressure
    end

    def geocentric_position
      n = earth_prime_vertical_radius_of_curvature
      x = (n + @elevation.m) * @latitude.cos * @longitude.cos
      y = (n + @elevation.m) * @latitude.cos * @longitude.sin
      z = (n * (1 - Constants::WGS84_ECCENTICITY_SQUARED) + @elevation.m) *
        @latitude.sin
      Distance.vector_from_meters([x, y, z])
    end

    def geocentric_velocity
      r = projected_radius
      vx = -Constants::EARTH_ANGULAR_VELOCITY_RAD_PER_S * r * @longitude.sin
      vy = Constants::EARTH_ANGULAR_VELOCITY_RAD_PER_S * r * @longitude.cos
      vz = 0.0
      Velocity.vector_from_mps([vx, vy, vz])
    end

    def earth_fixed_rotation_matrix_for(instant)
      gmst = GreenwichSiderealTime
        .from_utc(instant.to_time)
        .time

      dpsi = Nutation.new(instant: instant).nutation_in_longitude

      mean_obliquity = MeanObliquity.for_epoch(instant.tt)

      gast = Angle.from_radians(
        Angle.from_hours(gmst).radians +
          dpsi.radians * mean_obliquity.cos
      )

      earth_rotation_matrix = Matrix[
        [gast.cos, -gast.sin, 0],
        [gast.sin, gast.cos, 0],
        [0, 0, 1]
      ]

      nutation_matrix = Nutation.matrix_for(instant)
      precession_matrix = Precession.matrix_for(instant)

      earth_rotation_matrix * nutation_matrix * precession_matrix
    end

    def observe(celestial_body)
      celestial_body.observed_by(self)
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      @latitude == other.latitude &&
        @longitude == other.longitude &&
        @elevation == other.elevation &&
        @utc_offset == other.utc_offset &&
        @temperature == other.temperature &&
        @pressure == other.pressure
    end
    alias_method :eql?, :==

    def hash
      [
        self.class,
        @latitude,
        @longitude,
        @elevation,
        @utc_offset,
        @temperature,
        @pressure
      ].hash
    end

    private

    # @return [Float] the atmospheric pressure in millibars.
    def compute_pressure
      @pressure ||= PRESSURE_AT_SEA_LEVEL * pressure_ratio
    end

    # Source:
    # Barometric formula
    # https://en.wikipedia.org/wiki/Barometric_formula
    def pressure_ratio
      term1 = EARTH_GRAVITATIONAL_ACCELERATION *
        MOLAR_MASS_OF_AIR *
        @elevation.meters
      term2 = UNIVERSAL_GAS_CONSTANT * @temperature

      Math.exp(-term1 / term2)
    end

    def earth_prime_vertical_radius_of_curvature
      Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS./(
        Math.sqrt(
          1 -
            Constants::WGS84_ECCENTICITY_SQUARED * @latitude.sin * @latitude.sin
        )
      )
    end

    def projected_radius
      Math.sqrt(
        geocentric_position.x.m * geocentric_position.x.m +
          geocentric_position.y.m * geocentric_position.y.m
      )
    end
  end
end
