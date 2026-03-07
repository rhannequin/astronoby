# frozen_string_literal: true

module Astronoby
  # TEME (True Equator, Mean Equinox) reference frame. This is the output
  # frame of the SGP4/SDP4 satellite orbit propagators. Provides conversions
  # to ECEF, GCRS, and topocentric frames.
  class Teme < ReferenceFrame
    # ECEF position and velocity vectors.
    class EcefCoordinates
      # @return [Astronoby::Vector<Astronoby::Distance>] ECEF position
      attr_reader :position

      # @return [Astronoby::Vector<Astronoby::Velocity>] ECEF velocity
      attr_reader :velocity

      # @param position [Astronoby::Vector<Astronoby::Distance>] ECEF position
      # @param velocity [Astronoby::Vector<Astronoby::Velocity>] ECEF velocity
      def initialize(position:, velocity:)
        @position = position
        @velocity = velocity
        freeze
      end

      # Converts the ECEF position to WGS-84 geodetic coordinates using
      # Bowring's iterative method.
      #
      # @return [Astronoby::Coordinates::Geodetic] geodetic coordinates
      def geodetic
        Coordinates::Geodetic.from_ecef(@position)
      end
    end

    # @param position [Astronoby::Vector<Astronoby::Distance>] TEME position
    # @param velocity [Astronoby::Vector<Astronoby::Velocity>] TEME velocity
    # @param instant [Astronoby::Instant] the time instant
    def initialize(position:, velocity:, instant:)
      super(
        position: position,
        velocity: velocity,
        instant: instant,
        center_identifier: SolarSystemBody::EARTH,
        target_body: nil
      )
    end

    # Converts TEME position and velocity to ECEF using the canonical
    # Vallado formulation with R₃(GMST).
    #
    # Velocity includes the ω×r transport term to account for Earth
    # rotation.
    #
    # @return [Astronoby::Teme::EcefCoordinates] ECEF position and velocity
    def to_ecef
      mean_rotation_matrix = EarthRotation.mean_matrix_for(@instant).transpose

      position = mean_rotation_matrix * @position.map(&:m)
      velocity_mps = mean_rotation_matrix * @velocity.map(&:mps)

      omega = Constants::EARTH_ANGULAR_VELOCITY_RAD_PER_S
      corrected_vel = ::Vector[
        velocity_mps[0] + omega * position[1],
        velocity_mps[1] - omega * position[0],
        velocity_mps[2]
      ]

      EcefCoordinates.new(
        position: Distance.vector_from_meters(position),
        velocity: Velocity.vector_from_mps(corrected_vel)
      )
    end

    # Converts TEME to GCRS using the pragmatic approach: reuse existing
    # IAU 2006/2000B precession and nutation matrices transposed.
    #
    # The transformation chain is: r_GCRS = PBᵀ * Nᵀ * R₃(EoE) * r_TEME
    #
    # @return [Astronoby::Astrometric] GCRS Earth-centered frame
    def to_gcrs
      Astrometric.new(
        position: Distance.vector_from_meters(
          gcrs_rotation_matrix * @position.map(&:m)
        ),
        velocity: Velocity.vector_from_mps(
          gcrs_rotation_matrix * @velocity.map(&:mps)
        ),
        instant: @instant,
        center_identifier: SolarSystemBody::EARTH,
        target_body: nil
      )
    end

    # Converts TEME to topocentric coordinates as seen from an observer.
    #
    # Both satellite (via equation of equinoxes) and observer (via
    # R₃(GAST) * W) are placed in the TOD frame, then subtracted.
    #
    # @param observer [Astronoby::Observer] the observer
    # @return [Astronoby::Topocentric] topocentric frame
    def observed_by(observer)
      satellite_position = Distance.vector_from_meters(
        equation_of_equinoxes_matrix * @position.map(&:m)
      )
      satellite_velocity = Velocity.vector_from_mps(
        equation_of_equinoxes_matrix * @velocity.map(&:mps)
      )

      matrix = observer.earth_fixed_rotation_matrix_for(@instant)
      observer_position = Distance.vector_from_meters(
        matrix * observer.geocentric_position.map(&:m)
      )
      observer_velocity = Velocity.vector_from_mps(
        matrix * observer.geocentric_velocity.map(&:mps)
      )

      Topocentric.new(
        position: satellite_position - observer_position,
        velocity: satellite_velocity - observer_velocity,
        instant: @instant,
        center_identifier: [observer.longitude, observer.latitude],
        target_body: nil,
        observer: observer
      )
    end

    private

    def gcrs_rotation_matrix
      @gcrs_rotation_matrix ||= begin
        precession_matrix = Precession.matrix_for(@instant)
        nutation_matrix = Nutation.matrix_for(@instant)
        precession_matrix.transpose *
          nutation_matrix.transpose *
          equation_of_equinoxes_matrix
      end
    end

    def equation_of_equinoxes_matrix
      @equation_of_equinoxes_matrix ||= begin
        nutation = Nutation.new(instant: @instant)
        dpsi = nutation.nutation_in_longitude
        mean_obliquity = MeanObliquity.at(@instant)
        eoe = dpsi.radians * mean_obliquity.cos

        c, s = Math.cos(eoe), Math.sin(eoe)
        Matrix[
          [c, -s, 0],
          [s, c, 0],
          [0, 0, 1]
        ]
      end
    end
  end
end
