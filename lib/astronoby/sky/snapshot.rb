# frozen_string_literal: true

module Astronoby
  class Sky
    # Everything shared by the bodies observed at one instant: Earth's and the
    # Sun's geometric states, the precession and nutation matrices, and the
    # body instances themselves, so that a planet and the Sun at the same
    # instant compute these once.
    #
    # @api private
    class Snapshot
      attr_reader :instant

      # @param ephem [::Ephem::SPK] ephemeris data source
      # @param instant [Astronoby::Instant] the time instant
      # @param orientation [Astronoby::Orientation, nil] orientation kernel
      #   given to the bodies built from this snapshot
      def initialize(ephem:, instant:, orientation: nil)
        @ephem = ephem
        @instant = instant
        @orientation = orientation
      end

      # @param body_class [Class] a SolarSystemBody subclass
      # @return [Astronoby::Geometric] the body's geometric frame
      def geometric(body_class)
        return earth_geometric if body_class == Earth
        return sun_geometric if body_class == Sun

        (@geometrics ||= {})[body_class] ||=
          body_class.compute_geometric(ephem: @ephem, instant: @instant)
      end

      # @return [Astronoby::Geometric] Earth's geometric frame
      def earth_geometric
        @earth_geometric ||=
          Earth.compute_geometric(ephem: @ephem, instant: @instant)
      end

      # @return [Astronoby::Geometric] the Sun's geometric frame
      def sun_geometric
        @sun_geometric ||=
          Sun.compute_geometric(ephem: @ephem, instant: @instant)
      end

      # @param body_class [Class] a SolarSystemBody subclass
      # @return [Astronoby::SolarSystemBody] the body at this instant
      def body(body_class)
        (@bodies ||= {})[body_class] ||= body_class.new(
          ephem: @ephem,
          instant: @instant,
          orientation: @orientation,
          snapshot: self
        )
      end

      # Makes a body built outside the snapshot the one it returns for its
      # class, unless it already has one.
      #
      # @param body [Astronoby::SolarSystemBody] a body at this instant
      # @return [void]
      def register(body)
        (@bodies ||= {})[body.class] ||= body
      end

      # @return [Matrix] the precession-bias matrix at this instant
      def precession_matrix
        @precession_matrix ||= Precession.matrix_for(@instant)
      end

      # @return [Matrix] the nutation matrix at this instant
      def nutation_matrix
        @nutation_matrix ||= Nutation.matrix_for(@instant)
      end

      def inspect
        "#<#{self.class} #{@instant.inspect}>"
      end
    end
  end
end
