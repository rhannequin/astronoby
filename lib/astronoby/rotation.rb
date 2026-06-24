# frozen_string_literal: true

require "matrix"

module Astronoby
  # Builds elementary rotation matrices about the coordinate axes from an
  # +Astronoby::Angle+.
  #
  # These use the passive (frame) convention: the matrix expresses a fixed
  # vector in a frame rotated by +angle+ about the axis. This is the convention
  # used throughout the reference-frame chain (precession, nutation, body
  # orientation).
  module Rotation
    module_function

    # @param angle [Astronoby::Angle] the rotation angle
    # @return [Matrix] rotation about the x-axis
    def about_x(angle)
      cosine, sine = angle.cos, angle.sin
      Matrix[
        [1, 0, 0],
        [0, cosine, sine],
        [0, -sine, cosine]
      ]
    end

    # @param angle [Astronoby::Angle] the rotation angle
    # @return [Matrix] rotation about the y-axis
    def about_y(angle)
      cosine, sine = angle.cos, angle.sin
      Matrix[
        [cosine, 0, -sine],
        [0, 1, 0],
        [sine, 0, cosine]
      ]
    end

    # @param angle [Astronoby::Angle] the rotation angle
    # @return [Matrix] rotation about the z-axis
    def about_z(angle)
      cosine, sine = angle.cos, angle.sin
      Matrix[
        [cosine, sine, 0],
        [-sine, cosine, 0],
        [0, 0, 1]
      ]
    end
  end
end
