# frozen_string_literal: true

module Astronoby
  class Sky
    # A body of the sky, without an instant: a Solar System body read from the
    # sky's ephemeris, or a deep-sky object observed from the sky's Earth.
    class Target
      # @return [Class, Astronoby::DeepSkyObject] the body class, or the
      #   deep-sky object
      attr_reader :body

      # @api private
      # @param sky [Astronoby::Sky]
      # @param body [Class, Astronoby::DeepSkyObject] a SolarSystemBody
      #   subclass or a deep-sky object
      def initialize(sky:, body:)
        @sky = sky
        @body = body
      end

      # @param instant [Astronoby::Instant] the time instant
      # @return [Astronoby::SolarSystemBody, Astronoby::DeepSkyObjectPosition]
      #   the body at the instant
      def at(instant)
        if @body.is_a?(DeepSkyObject)
          @body.at(instant, ephem: @sky.ephem)
        else
          @sky.snapshot_at(instant).body(@body)
        end
      end

      # @return [Astronoby::Sky::TargetPoint] the target's centre
      def center
        TargetPoint.new(target: self, reference: :center)
      end

      # @return [Astronoby::Sky::TargetPoint] the top edge of the target's
      #   disk, using its true semi-diameter
      # @raise [ArgumentError] for a deep-sky object, which has no known size
      def upper_limb
        limb(:upper_limb)
      end

      # @return [Astronoby::Sky::TargetPoint] the bottom edge of the target's
      #   disk, using its true semi-diameter
      # @raise [ArgumentError] for a deep-sky object, which has no known size
      def lower_limb
        limb(:lower_limb)
      end

      def inspect
        "#<#{self.class} #{description}>"
      end

      private

      def limb(reference)
        if @body.is_a?(DeepSkyObject)
          raise ArgumentError, "A deep-sky object has no limb"
        end

        TargetPoint.new(target: self, reference: reference)
      end

      def description
        return @body.name unless @body.is_a?(DeepSkyObject)

        coordinates = @body.equatorial_coordinates
        "#{coordinates.right_ascension.str(:hms)} " \
          "#{coordinates.declination.str(:dms)}"
      end
    end
  end
end
