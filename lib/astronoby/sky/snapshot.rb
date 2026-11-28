# frozen_string_literal: true

module Astronoby
  class Sky
    # @api private
    class Snapshot
      attr_reader :instant

      def initialize(ephem:, instant:, orientation: nil)
        @ephem = ephem
        @instant = instant
        @orientation = orientation
      end

      def geometric(body_class)
        return earth_geometric if body_class == Earth
        return sun_geometric if body_class == Sun

        (@geometrics ||= {})[body_class] ||=
          body_class.compute_geometric(ephem: @ephem, instant: @instant)
      end

      def earth_geometric
        @earth_geometric ||=
          Earth.compute_geometric(ephem: @ephem, instant: @instant)
      end

      def sun_geometric
        @sun_geometric ||=
          Sun.compute_geometric(ephem: @ephem, instant: @instant)
      end

      def body(body)
        (@bodies ||= {})[body] ||=
          if body.is_a?(Class) && body <= SolarSystemBody
            body.new(
              ephem: @ephem,
              instant: @instant,
              orientation: @orientation,
              snapshot: self
            )
          elsif body.is_a?(DeepSkyObject)
            body.position_at(@instant, ephem: @ephem)
          else
            body.at(@instant, ephem: @ephem)
          end
      end

      def register(body)
        (@bodies ||= {})[body.class] ||= body
      end

      def precession_matrix
        @precession_matrix ||= Precession.matrix_for(@instant)
      end

      def nutation_matrix
        @nutation_matrix ||= Nutation.matrix_for(@instant)
      end

      def inspect
        "#<#{self.class} #{@instant.inspect}>"
      end
    end
  end
end
