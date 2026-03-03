# frozen_string_literal: true

module Astronoby
  # Base class for reference frames in the astronomical reference frame chain.
  # Each frame represents a body's position and velocity relative to a center,
  # at a specific instant.
  class ReferenceFrame
    # @return [Astronoby::Vector<Astronoby::Distance>] position vector
    attr_reader :position

    # @return [Astronoby::Vector<Astronoby::Velocity>] velocity vector
    attr_reader :velocity

    # @return [Astronoby::Instant] the time instant
    attr_reader :instant

    # @return [Integer, Array] identifier for the center of the frame
    attr_reader :center_identifier

    # @return [Class, Object] the target body
    attr_reader :target_body

    # @param position [Astronoby::Vector<Astronoby::Distance>] position vector
    # @param velocity [Astronoby::Vector<Astronoby::Velocity>] velocity vector
    # @param instant [Astronoby::Instant] the time instant
    # @param center_identifier [Integer, Array] identifier for the center
    # @param target_body [Class, Object] the target body
    def initialize(
      position:,
      velocity:,
      instant:,
      center_identifier:,
      target_body:
    )
      @position = position
      @velocity = velocity
      @instant = instant
      @center_identifier = center_identifier
      @target_body = target_body
    end

    # @return [Astronoby::Coordinates::Equatorial] equatorial coordinates
    #   derived from the position vector
    def equatorial
      @equatorial ||= begin
        return Coordinates::Equatorial.zero if distance.zero?

        Coordinates::Equatorial.from_position_vector(@position)
      end
    end

    # @return [Astronoby::Coordinates::Ecliptic] ecliptic coordinates derived
    #   from the equatorial coordinates at J2000.0
    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        j2000 = Instant.from_terrestrial_time(JulianDate::J2000)
        equatorial.to_ecliptic(instant: j2000)
      end
    end

    # @return [Astronoby::Distance] the Euclidean distance from the center
    def distance
      @distance ||= begin
        return Distance.zero if @position.zero?

        @position.magnitude
      end
    end
  end
end
