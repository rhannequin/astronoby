# frozen_string_literal: true

module Astronoby
  # Computes Earth rotation matrices using Greenwich Sidereal Time.
  # Provides both apparent (GAST-based) and mean (GMST-based) rotation
  # matrices for transforming between Earth-fixed and celestial frames.
  class EarthRotation
    # Computes the apparent Earth rotation matrix R₃(GAST) for a given
    # instant.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @return [Matrix] 3x3 Earth rotation matrix
    def self.matrix_for(instant)
      new(instant: instant).matrix
    end

    # Computes the mean Earth rotation matrix R₃(GMST) for a given
    # instant.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @return [Matrix] 3x3 mean Earth rotation matrix
    def self.mean_matrix_for(instant)
      new(instant: instant).mean_matrix
    end

    # @param instant [Astronoby::Instant] the time instant
    def initialize(instant:)
      @instant = instant
    end

    # Computes R₃(GAST), the apparent Earth rotation matrix.
    # GAST = GMST + equation of the equinoxes (Δψ cos ε₀).
    #
    # @return [Matrix] 3x3 rotation matrix
    def matrix
      rotation_matrix_for(gast)
    end

    # Computes R₃(GMST), the mean Earth rotation matrix.
    #
    # @return [Matrix] 3x3 rotation matrix
    def mean_matrix
      rotation_matrix_for(gmst)
    end

    private

    def gmst
      Angle.from_hours(@instant.gmst)
    end

    def gast
      nutation = Nutation.new(instant: @instant)
      dpsi = nutation.nutation_in_longitude
      mean_obliquity = MeanObliquity.at(@instant)
      Angle.from_radians(
        gmst.radians + dpsi.radians * mean_obliquity.cos
      )
    end

    def rotation_matrix_for(angle)
      c, s = angle.cos, angle.sin
      Matrix[
        [c, -s, 0],
        [s, c, 0],
        [0, 0, 1]
      ]
    end
  end
end
