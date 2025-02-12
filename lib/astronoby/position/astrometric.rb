# frozen_string_literal: true

module Astronoby
  module Position
    class Astrometric < ICRF
      def right_ascension
        return Angle.zero if distance.zero?

        term1 = @position.y.m
        term2 = @position.x.m
        angle = Angle.atan(term1 / term2)

        Astronoby::Util::Trigonometry.adjustement_for_arctangent(
          term1,
          term2,
          angle
        )
      end

      def declination
        return Angle.zero if distance.zero?

        Astronoby::Angle.asin(@position.z.m / distance.m)
      end

      def distance
        return Distance.zero if @position.zero?

        Astronoby::Distance.from_meters(@position.magnitude)
      end
    end
  end
end
