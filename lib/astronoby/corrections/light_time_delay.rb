# frozen_string_literal: true

module Astronoby
  module Correction
    class LightTimeDelay
      LIGHT_SPEED_CORRECTION_MAXIMUM_ITERATIONS = 10
      LIGHT_SPEED_CORRECTION_PRECISION = 1e-12

      def self.compute(center:, target:, ephem:)
        new(center: center, target: target, ephem: ephem).compute
      end

      def initialize(center:, target:, ephem:)
        @center = center
        @target = target
        @ephem = ephem
      end

      def delay
        @_delay ||= begin
          compute
          @delay
        end
      end

      def compute
        @corrected_position ||= begin
          corrected_position = Vector[
            Distance.zero,
            Distance.zero,
            Distance.zero
          ]
          corrected_velocity = Vector[
            Velocity.zero,
            Velocity.zero,
            Velocity.zero
          ]
          @delay = initial_delta_in_seconds

          LIGHT_SPEED_CORRECTION_MAXIMUM_ITERATIONS.times do
            new_instant = Instant.from_terrestrial_time(
              instant.tt - @delay / Constants::SECONDS_PER_DAY
            )
            corrected = @target
              .target_body
              .barycentric(ephem: @ephem, instant: new_instant)
            corrected_position = corrected.position
            corrected_velocity = corrected.velocity

            corrected_distance_in_km = Math.sqrt(
              (corrected_position.x.km - position.x.km)**2 +
                (corrected_position.y.km - position.y.km)**2 +
                (corrected_position.z.km - position.z.km)**2
            )

            new_delay = corrected_distance_in_km / Velocity.light_speed.kmps

            break if (new_delay - @delay).abs < LIGHT_SPEED_CORRECTION_PRECISION

            @delay = new_delay
          end

          [corrected_position, corrected_velocity]
        end
      end

      private

      def position
        @position ||= @center.position
      end

      def instant
        @center.instant
      end

      def initial_delta_in_seconds
        distance_between_bodies_in_km / Velocity.light_speed.kmps
      end

      def distance_between_bodies_in_km
        Math.sqrt(
          (@target.position.x.km - position.x.km)**2 +
            (@target.position.y.km - position.y.km)**2 +
            (@target.position.z.km - position.z.km)**2
        )
      end
    end
  end
end
