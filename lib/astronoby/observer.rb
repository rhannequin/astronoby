# frozen_string_literal: true

module Astronoby
  class Observer
    DEFAULT_ELEVATION = Distance.zero
    DEFAULT_TEMPERATURE = Temperature.from_celsius(10)

    # @return [Astronoby::Angle] geographic latitude
    attr_reader :latitude

    # @return [Astronoby::Angle] geographic longitude
    attr_reader :longitude

    # @return [Astronoby::Distance] geographic elevation above sea level
    attr_reader :elevation

    # @return [Numeric, String] offset from Coordinated Universal Time
    attr_reader :utc_offset

    # @return [Astronoby::Temperature] temperature of the air at the observer's
    #   location
    attr_reader :temperature

    # @return [Astronoby::Pressure] atmospheric pressure at the observer's
    #   location
    attr_reader :pressure

    # @param latitude [Astronoby::Angle] geographic latitude of the observer
    # @param longitude [Astronoby::Angle] geographic longitude of the observer
    # @param elevation [Astronoby::Distance] geographic elevation (or altitude)
    #   of the observer above sea level
    # @param utc_offset [Numeric, String] offset from Coordinated Universal Time
    # @param temperature [Astronoby::Temperature] temperature of the air at the
    #   observer's location, 10 °C by default
    # @param pressure [Astronoby::Pressure, nil] atmospheric pressure at the
    #   observer's location, derived from the elevation and the temperature by
    #   default
    # @raise [Astronoby::IncompatibleArgumentsError] if the temperature or the
    #   pressure is not a value object
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
      @temperature = ensure_value_object!(:temperature, temperature, Temperature)
      @pressure = ensure_value_object!(
        :pressure,
        pressure || Pressure.at_elevation(elevation, temperature: temperature),
        Pressure
      )
    end

    # Returns the observer's ECEF position vector (WGS-84 geodetic to ECEF).
    #
    # @return [Astronoby::Vector<Astronoby::Distance>] geocentric position
    def geocentric_position
      @geocentric_position ||= begin
        n = earth_prime_vertical_radius_of_curvature
        x = (n + @elevation.m) * @latitude.cos * @longitude.cos
        y = (n + @elevation.m) * @latitude.cos * @longitude.sin
        z = (n * (1 - Constants::WGS84_ECCENTICITY_SQUARED) + @elevation.m) *
          @latitude.sin
        Distance.vector_from_meters([x, y, z])
      end
    end

    # Returns the observer's ECEF velocity vector due to Earth rotation.
    #
    # @return [Astronoby::Vector<Astronoby::Velocity>] geocentric velocity
    def geocentric_velocity
      @geocentric_velocity ||= begin
        r = projected_radius
        vx = -Constants::EARTH_ANGULAR_VELOCITY_RAD_PER_S * r * @longitude.sin
        vy = Constants::EARTH_ANGULAR_VELOCITY_RAD_PER_S * r * @longitude.cos
        vz = 0.0
        Velocity.vector_from_mps([vx, vy, vz])
      end
    end

    # Computes the Earth-fixed rotation matrix R₃(GAST) * W (polar motion)
    # for a given instant.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @return [Matrix] 3x3 rotation matrix
    def earth_fixed_rotation_matrix_for(instant)
      EarthRotation.matrix_for(instant) * polar_motion_matrix_for(instant)
    end

    # @param other [Astronoby::Observer] observer to compare with
    # @return [Boolean] true if all attributes are equal
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

    # @return [Integer] hash value
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

    def ensure_value_object!(name, value, klass)
      return value if value.is_a?(klass)

      raise IncompatibleArgumentsError,
        "Expected #{name} to be an #{klass}, got #{value.inspect}"
    end

    def polar_motion_matrix_for(instant)
      rows = IERS::PolarMotion.rotation_matrix_at(instant.to_time)
      Matrix[*rows]
    rescue IERS::OutOfRangeError
      Matrix.identity(3)
    end

    def earth_prime_vertical_radius_of_curvature
      @earth_prime_vertical_radius_of_curvature ||=
        Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS./(
          Math.sqrt(
            1 -
              Constants::WGS84_ECCENTICITY_SQUARED * @latitude.sin * @latitude.sin
          )
        )
    end

    def projected_radius
      @projected_radius ||= begin
        pos = geocentric_position
        Math.sqrt(pos.x.m * pos.x.m + pos.y.m * pos.y.m)
      end
    end
  end
end
