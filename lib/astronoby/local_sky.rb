# frozen_string_literal: true

module Astronoby
  # The sky as seen by one observer: everything that depends on where they
  # stand. Each method returns an {Astronoby::Events::Series}, read with
  # +on+, +between+ or +from+.
  #
  # @example
  #   local_sky = sky.over(observer)
  #   local_sky.passes(sky.saturn).on(date)
  #   local_sky.risings(sky.moon).from(instant).first(3)
  class LocalSky
    WINDOW_IN_DAYS = 1
    HORIZON_IN_DAYS = 366

    TWILIGHT_ALTITUDES = {
      civil: Angle.from_degrees(-6),
      nautical: Angle.from_degrees(-12),
      astronomical: Angle.from_degrees(-18)
    }.freeze

    UNREACHABLE_MARGIN = Angle.from_degrees(1)

    # @return [Astronoby::Observer]
    attr_reader :observer

    # @api private
    def initialize(sky:, observer:)
      @sky = sky
      @observer = observer
    end

    # @param target [Astronoby::Sky::Target, Astronoby::Sky::TargetPoint,
    #   Astronoby::DeepSkyObject] what crosses the altitude, its centre unless
    #   a limb is given
    # @param altitude [Astronoby::Altitude] the altitude to cross
    # @return [Astronoby::Events::Series] of Astronoby::AltitudeCrossing
    def crossings(target, altitude)
      body, reference = body_and_reference(target)
      calculator = AltitudeCrossingCalculator.new(
        body: body,
        observer: @observer,
        ephem: @sky.ephem,
        refraction: altitude.apparent?,
        reference: reference
      )
      series(time_of: :instant.to_proc) do |start_instant, end_instant|
        next [] if unreachable?(body, altitude.angle, start_instant)

        calculator
          .search_between(start_instant, end_instant)
          .crossings([altitude.angle])
          .first
      end
    end

    # Upper and lower culminations of the target: its highest and lowest
    # points as it crosses the meridian, with its altitude at each.
    #
    # @param target [Astronoby::Sky::Target, Astronoby::Sky::TargetPoint,
    #   Astronoby::DeepSkyObject] whose altitude is given, its centre unless a
    #   limb is given
    # @param refraction [Boolean] whether the altitude includes atmospheric
    #   refraction, which is held at its value at -1° below that altitude, so
    #   a refracted altitude far below the horizon has no physical meaning
    # @return [Astronoby::Events::Series] of Astronoby::AltitudeExtreme
    def culminations(target, refraction: false)
      body, reference = body_and_reference(target)
      calculator = AltitudeCrossingCalculator.new(
        body: body,
        observer: @observer,
        ephem: @sky.ephem,
        refraction: refraction,
        reference: reference
      )
      series(time_of: :instant.to_proc) do |start_instant, end_instant|
        calculator.search_between(start_instant, end_instant).extremes
      end
    end

    # Each passage of the target across the meridian, dated by its transit,
    # with the rising before it and the setting after it. Rising and setting
    # follow each body's standard horizon: the Sun's and the Moon's upper
    # limb, refraction included.
    #
    # @param target [Astronoby::Sky::Target, Astronoby::DeepSkyObject]
    # @return [Astronoby::Events::Series] of Astronoby::Pass
    def passes(target)
      body = horizon_body(target)

      series(time_of: :transit.to_proc) do |start_instant, end_instant|
        rise_transit_set_calculator(body)
          .passes_between(start_instant, end_instant)
          .map do |rising, transit, setting|
            Pass.new(rising: rising, transit: transit, setting: setting)
          end
      end
    end

    # @param target [Astronoby::Sky::Target, Astronoby::DeepSkyObject]
    # @return [Astronoby::Events::Series] of Astronoby::Instant
    def risings(target)
      horizon_events(target, :rising)
    end

    # @param target [Astronoby::Sky::Target, Astronoby::DeepSkyObject]
    # @return [Astronoby::Events::Series] of Astronoby::Instant
    def transits(target)
      horizon_events(target, :transit)
    end

    # @param target [Astronoby::Sky::Target, Astronoby::DeepSkyObject]
    # @return [Astronoby::Events::Series] of Astronoby::Instant
    def settings(target)
      horizon_events(target, :setting)
    end

    # Civil, nautical and astronomical dawns and dusks: the Sun's centre
    # crossing 6°, 12° and 18° below the horizon, without refraction.
    #
    # @return [Astronoby::Events::Series] of Astronoby::TwilightCrossing
    def twilights
      calculator = AltitudeCrossingCalculator.new(
        body: Sun,
        observer: @observer,
        ephem: @sky.ephem
      )
      series(time_of: :instant.to_proc) do |start_instant, end_instant|
        found = calculator
          .search_between(start_instant, end_instant)
          .crossings(TWILIGHT_ALTITUDES.values)
        TWILIGHT_ALTITUDES.keys.zip(found).flat_map do |kind, crossings|
          crossings.map do |crossing|
            TwilightCrossing.new(
              instant: crossing.instant,
              direction: crossing.direction,
              kind: kind,
              grazing: crossing.grazing?
            )
          end
        end
      end
    end

    def inspect
      "#<#{self.class} #{@observer.latitude.str(:dms)} " \
        "#{@observer.longitude.str(:dms)}>"
    end

    private

    def body_and_reference(target)
      case target
      when Sky::TargetPoint then [target.target.body, target.reference]
      when Sky::Target then [target.body, :center]
      when DeepSkyObject then [target, :center]
      else
        raise ArgumentError,
          "Expected a target of the sky or a deep-sky object, " \
          "got #{target.inspect}"
      end
    end

    def horizon_body(target)
      body, reference = body_and_reference(target)
      unless reference == :center
        raise ArgumentError,
          "Risings, transits and settings follow each body's standard " \
          "horizon; use crossings for a limb"
      end

      body
    end

    def horizon_events(target, event_type)
      body = horizon_body(target)

      series(time_of: :itself.to_proc) do |start_instant, end_instant|
        if event_type != :transit &&
            unreachable?(body, Horizon::REFRACTION_ANGLE, start_instant)
          next []
        end

        rise_transit_set_calculator(body)
          .instants_between(start_instant, end_instant, event_type)
      end
    end

    def rise_transit_set_calculator(body)
      RiseTransitSetCalculator.new(
        body: body,
        observer: @observer,
        ephem: @sky.ephem
      )
    end

    def unreachable?(body, altitude, instant)
      return false unless body.is_a?(DeepSkyObject)

      declination = body.at(instant).apparent.equatorial.declination.radians
      latitude = @observer.latitude.radians
      highest = Math::PI / 2 - (latitude - declination).abs
      lowest = (latitude + declination).abs - Math::PI / 2
      margin = UNREACHABLE_MARGIN.radians

      altitude.radians > highest + margin || altitude.radians < lowest - margin
    end

    def series(time_of:, &search)
      Events::Series.new(
        window: WINDOW_IN_DAYS,
        horizon: HORIZON_IN_DAYS,
        time_of: time_of,
        last_tt: @sky.ephem.coverage.last,
        &search
      )
    end
  end
end
