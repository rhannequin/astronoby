# frozen_string_literal: true

require "ephem"
require "matrix"

module Astronoby
  # Wraps a binary PCK lunar orientation kernel (for example
  # +moon_pa_de440_200625.bpc+) and exposes the rotation from the inertial frame
  # (J2000/ICRF) to the Moon's mean-Earth (ME) body-fixed frame at a given
  # instant.
  #
  # A binary kernel only provides the principal-axis (PA) orientation, and which
  # PA frame it describes is read from the kernel itself. JPL Horizons and IMCCE
  # report selenographic positions in the mean-Earth frame, whose small fixed
  # offset from the principal axes is published in the NAIF lunar frame kernels
  # (the +moon_*.tf+ files) rather than in the binary kernel. That alignment is
  # essentially constant across ephemeris versions (below 0.15 arcsecond), so
  # the DE440 values are applied here.
  class Orientation
    # Principal-axis to mean-Earth alignment from the NAIF DE440 lunar frame
    # kernel (moon_de440_250416.tf): the rotation angles about the z, y and x
    # axes that align the principal-axis frame with the mean-Earth frame.
    MEAN_EARTH_ALIGNMENT = [
      Angle.from_degree_arcseconds(67.8526),
      Angle.from_degree_arcseconds(78.6944),
      Angle.from_degree_arcseconds(0.2785)
    ].freeze

    # Download a binary PCK orientation kernel.
    #
    # @param name [String] kernel name supported by the Ephem gem
    # @param target [String] destination path
    # @return [Boolean] true if the download was successful
    def self.download(name:, target:)
      ::Ephem::Download.call(name: name, target: target)
    end

    # Load a binary PCK orientation kernel.
    #
    # @param target [String] path to the +.bpc+ file
    # @return [Astronoby::Orientation]
    # @raise [Astronoby::OrientationError] if the kernel has no orientation data
    def self.load(target)
      new(::Ephem::PCK.open(target))
    end

    # @param pck [::Ephem::PCK] an opened binary PCK
    def initialize(pck)
      @pck = pck
      @source = orientation_source
      @mean_earth_rotation = mean_earth_rotation
      @start_jd = @pck.segments.map(&:start_jd).min
      @end_jd = @pck.segments.map(&:end_jd).max
    end

    # Rotation from the inertial frame (J2000/ICRF) to the Moon's mean-Earth
    # body-fixed frame.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @return [Matrix] a 3x3 rotation matrix
    # @raise [Astronoby::OrientationOutOfRangeError] if the kernel does not
    #   cover the instant
    def rotation_for(instant)
      @mean_earth_rotation * principal_axis_rotation(instant)
    end

    # @return [void]
    def close
      @pck.close
    end

    private

    # The orientation source for the body frame the kernel describes, read from
    # the kernel rather than assumed.
    def orientation_source
      segment = @pck.segments.first
      raise OrientationError, "Orientation kernel has no segments" unless segment

      @pck[segment.target]
    end

    # Inertial -> principal-axis rotation from the binary kernel's Euler angles.
    def principal_axis_rotation(instant)
      terrestrial_time = instant.terrestrial_time
      unless terrestrial_time.between?(@start_jd, @end_jd)
        raise OrientationOutOfRangeError,
          "Orientation kernel covers #{date(@start_jd)} to #{date(@end_jd)}; " \
          "requested #{date(terrestrial_time)}"
      end

      Matrix[*@source.matrix_at(terrestrial_time)]
    end

    # Principal-axis -> mean-Earth rotation (constant), about the x, y, z axes.
    def mean_earth_rotation
      about_z, about_y, about_x = MEAN_EARTH_ALIGNMENT
      Rotation.about_x(-about_x) *
        Rotation.about_y(-about_y) *
        Rotation.about_z(-about_z)
    end

    def date(terrestrial_time)
      Instant.from_terrestrial_time(terrestrial_time).to_time.utc.to_date
    end
  end
end
