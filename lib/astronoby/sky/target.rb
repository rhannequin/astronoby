# frozen_string_literal: true

module Astronoby
  class Sky
    # A body of the sky, without an instant: a Solar System body read from the
    # sky's ephemeris, or a deep-sky object observed from the sky's Earth.
    class Target
      YEAR_IN_DAYS = 365.25
      MONTH_IN_DAYS = 31
      HORIZON_IN_DAYS = 100 * YEAR_IN_DAYS
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

      # @return [Astronoby::Events::Series] of Astronoby::Opposition
      # @raise [Astronoby::UnsupportedEventError] unless the target is a
      #   superior planet
      def oppositions
        unless solar_system_body? && @body.superior_planet?
          raise UnsupportedEventError, "#{name} has no oppositions with the Sun"
        end

        calculator = conjunction_opposition_calculator
        series(window: YEAR_IN_DAYS) do |start_instant, end_instant|
          calculator.opposition_events_between(start_instant, end_instant)
        end
      end

      # @return [Astronoby::Events::Series] of Astronoby::Conjunction
      # @raise [Astronoby::UnsupportedEventError] unless the target is a planet
      def conjunctions
        unless solar_system_body? && @body.planet?
          raise UnsupportedEventError, "#{name} has no conjunctions with the Sun"
        end

        calculator = conjunction_opposition_calculator
        series(window: YEAR_IN_DAYS) do |start_instant, end_instant|
          calculator.conjunction_events_between(start_instant, end_instant)
        end
      end

      # @return [Astronoby::Events::Series] of Astronoby::GreatestElongation
      # @raise [Astronoby::UnsupportedEventError] unless the target is an
      #   inferior planet
      def greatest_elongations
        unless solar_system_body? && @body.inferior_planet?
          raise UnsupportedEventError,
            "#{name} has no greatest elongations from the Sun"
        end

        calculator = GreatestElongationCalculator.new(
          body: @body,
          ephem: @sky.ephem
        )
        series(window: YEAR_IN_DAYS) do |start_instant, end_instant|
          calculator.greatest_elongation_events_between(
            start_instant,
            end_instant
          )
        end
      end

      # @return [Astronoby::Events::Series] of Astronoby::LunarEclipse
      # @raise [Astronoby::UnsupportedEventError] unless the target is the
      #   Moon
      def eclipses
        moon_only!("eclipses")
        calculator = LunarEclipseCalculator.new(ephem: @sky.ephem)
        series(window: YEAR_IN_DAYS) do |start_instant, end_instant|
          calculator.events_between(start_instant, end_instant)
        end
      end

      # New moons, first quarters, full moons and last quarters: when the
      # difference between the Moon's and the Sun's apparent ecliptic
      # longitudes reaches 0°, 90°, 180° or 270°.
      #
      # @return [Astronoby::Events::Series] of Astronoby::MoonPhase
      # @raise [Astronoby::UnsupportedEventError] unless the target is the
      #   Moon
      def phases
        moon_only!("phases")
        calculator = MoonPhaseCalculator.new(ephem: @sky.ephem)
        series(window: MONTH_IN_DAYS) do |start_instant, end_instant|
          calculator.phases_between(start_instant, end_instant)
        end
      end

      def inspect
        "#<#{self.class} #{description}>"
      end

      private

      def solar_system_body?
        !@body.is_a?(DeepSkyObject)
      end

      def name
        solar_system_body? ? @body.name : "A deep-sky object"
      end

      def moon_only!(events)
        return if @body == Moon

        raise UnsupportedEventError, "Only the Moon has #{events}"
      end

      def conjunction_opposition_calculator
        ConjunctionOppositionCalculator.new(body: @body, ephem: @sky.ephem)
      end

      def series(window:, &search)
        Events::Series.new(
          window: window,
          horizon: HORIZON_IN_DAYS,
          time_of: :instant.to_proc,
          last_tt: @sky.ephem.coverage.last,
          &search
        )
      end

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
