# frozen_string_literal: true

module Astronoby
  class LunarEclipseVisibility
    NOT_VISIBLE = :not_visible
    ENTIRELY_VISIBLE = :entirely_visible
    BEGINS_BEFORE_MOONRISE = :begins_before_moonrise
    ENDS_AFTER_MOONSET = :ends_after_moonset
    PARTIALLY_VISIBLE = :partially_visible

    PHASES = [
      LunarEclipse::PENUMBRAL,
      LunarEclipse::PARTIAL,
      LunarEclipse::TOTAL
    ].freeze

    SAMPLING_INTERVAL_IN_DAYS =
      3.0 / Constants::HOURS_PER_DAY / Constants::MINUTES_PER_HOUR

    RADIANS_PER_HOUR =
      Constants::RADIANS_PER_CIRCLE / Constants::HOURS_PER_DAY

    private_constant :SAMPLING_INTERVAL_IN_DAYS
    private_constant :RADIANS_PER_HOUR

    # @return [Astronoby::LunarEclipse] the eclipse
    attr_reader :eclipse

    # @return [Astronoby::Observer] the observer
    attr_reader :observer

    # @param eclipse [Astronoby::LunarEclipse] the eclipse
    # @param observer [Astronoby::Observer] the observer
    def initialize(eclipse:, observer:)
      @eclipse = eclipse
      @observer = observer

      nodes = interpolation_nodes(eclipse)
      @node_times = nodes.map { |node| node[:jd] }
      @node_declinations = nodes.map { |node| node[:declination] }
      @node_distances = nodes.map { |node| node[:distance] }
      @node_right_ascensions = unwrapped(
        nodes.map { |node| node[:right_ascension] }
      )

      @window_start = eclipse.penumbral.starting_instant.tt
      @window_end = eclipse.penumbral.ending_instant.tt

      @anchor = eclipse.instant.tt
      @anchor_sidereal_hours = eclipse.instant.gast

      @sin_latitude = observer.latitude.sin
      @cos_latitude = observer.latitude.cos
      @longitude = observer.longitude.radians

      position = observer.geocentric_position
      @observer_x = position.x.m
      @observer_y = position.y.m
      @observer_z = position.z.m

      @memo = {}
      freeze
    end

    # @return [Boolean] true if any part of the eclipse happens with the Moon
    #   above the horizon
    def visible?
      !observable_windows.empty?
    end

    # @return [Boolean] true if the Moon is above the horizon from the first to
    #   the last penumbral contact
    def entirely_visible?
      observable_windows.one? &&
        above_horizon?(@window_start) &&
        above_horizon?(@window_end)
    end

    # @return [Symbol] +NOT_VISIBLE+, +ENTIRELY_VISIBLE+,
    #   +BEGINS_BEFORE_MOONRISE+, +ENDS_AFTER_MOONSET+ or +PARTIALLY_VISIBLE+
    def circumstance
      return NOT_VISIBLE unless visible?
      return ENTIRELY_VISIBLE if entirely_visible?
      return PARTIALLY_VISIBLE unless observable_windows.one?

      if above_horizon?(@window_end)
        BEGINS_BEFORE_MOONRISE
      elsif above_horizon?(@window_start)
        ENDS_AFTER_MOONSET
      else
        PARTIALLY_VISIBLE
      end
    end

    # @param phase [Symbol] +LunarEclipse::PENUMBRAL+,
    #   +LunarEclipse::PARTIAL+ or +LunarEclipse::TOTAL+
    # @return [Symbol, nil] +ENTIRELY_VISIBLE+, +PARTIALLY_VISIBLE+ or
    #   +NOT_VISIBLE+, and nil when the eclipse has no such phase
    # @raise [Astronoby::UnsupportedEventError] if the phase is not a phase of
    #   a lunar eclipse
    def coverage(phase)
      unless PHASES.include?(phase)
        raise UnsupportedEventError,
          "phase must be one of #{PHASES.join(", ")}, got #{phase.inspect}"
      end

      eclipse_phase = @eclipse.public_send(phase)
      return nil if eclipse_phase.nil?

      starting = eclipse_phase.starting_instant.tt
      ending = eclipse_phase.ending_instant.tt
      crossed_within = horizon_crossing_times.any? do |time|
        time > starting && time < ending
      end
      starts_up = above_horizon?(starting)
      ends_up = above_horizon?(ending)

      if crossed_within
        PARTIALLY_VISIBLE
      elsif starts_up && ends_up
        ENTIRELY_VISIBLE
      elsif starts_up || ends_up
        PARTIALLY_VISIBLE
      else
        NOT_VISIBLE
      end
    end

    # @param instant [Astronoby::Instant] an instant of the eclipse
    # @return [Boolean] true if the Moon is above the horizon then
    # @raise [ArgumentError] if the instant is outside the eclipse
    def above_horizon_at?(instant)
      above_horizon?(within_eclipse(instant))
    end

    # @return [Array<Astronoby::Instant>] the instants of the eclipse at which
    #   the Moon rises or sets, in time order
    def horizon_crossings
      @memo[:horizon_crossings] ||= horizon_crossing_times
        .map { |time| Instant.from_terrestrial_time(time) }
    end

    # @return [Array<Range<Astronoby::Instant>>] the observable stretches, in
    #   time order
    def observable_windows
      @memo[:observable_windows] ||= begin
        boundaries = [@window_start, *horizon_crossing_times, @window_end]
        boundaries.each_cons(2).filter_map do |starting, ending|
          next unless above_horizon?((starting + ending) / 2.0)

          Range.new(
            Instant.from_terrestrial_time(starting),
            Instant.from_terrestrial_time(ending)
          )
        end
      end
    end

    private

    def interpolation_nodes(eclipse)
      phases = [eclipse.partial, eclipse.total].compact
      contacts = [
        [eclipse.penumbral.starting_instant, eclipse.penumbral.starting_geometry],
        [eclipse.penumbral.ending_instant, eclipse.penumbral.ending_geometry],
        [eclipse.instant, eclipse.geometry],
        *phases.flat_map do |phase|
          [
            [phase.starting_instant, phase.starting_geometry],
            [phase.ending_instant, phase.ending_geometry]
          ]
        end
      ]

      contacts.sort_by { |instant, _| instant.tt }.map do |instant, geometry|
        coordinates = geometry.moon_coordinates

        {
          jd: instant.tt,
          right_ascension: coordinates.right_ascension.radians,
          declination: coordinates.declination.radians,
          distance: geometry.moon_distance.m
        }
      end
    end

    def unwrapped(right_ascensions)
      right_ascensions.each_with_object([]) do |value, unwrapped|
        previous = unwrapped.last
        if previous.nil?
          unwrapped << value
        else
          turns = ((value - previous) / Constants::RADIANS_PER_CIRCLE).round
          unwrapped << value - turns * Constants::RADIANS_PER_CIRCLE
        end
      end
    end

    def above_horizon?(time)
      clearance(time).positive?
    end

    def clearance(time)
      right_ascension, declination, distance = place(time)
      horizon = Horizon::REFRACTION_ANGLE.radians -
        Horizon.moon_semidiameter_radians(distance)

      altitude_of(right_ascension, declination, distance, time) - horizon
    end

    def altitude_of(right_ascension, declination, distance, time)
      sidereal = sidereal_radians_at(time)
      cos_declination = Math.cos(declination)
      moon_x = distance * cos_declination * Math.cos(right_ascension)
      moon_y = distance * cos_declination * Math.sin(right_ascension)
      moon_z = distance * Math.sin(declination)

      cos_sidereal = Math.cos(sidereal)
      sin_sidereal = Math.sin(sidereal)
      observer_x = @observer_x * cos_sidereal - @observer_y * sin_sidereal
      observer_y = @observer_x * sin_sidereal + @observer_y * cos_sidereal

      x = moon_x - observer_x
      y = moon_y - observer_y
      z = moon_z - @observer_z

      local_sidereal = sidereal + @longitude
      up_x = @cos_latitude * Math.cos(local_sidereal)
      up_y = @cos_latitude * Math.sin(local_sidereal)
      up_z = @sin_latitude

      cosine = (x * up_x + y * up_y + z * up_z) /
        Math.sqrt(x * x + y * y + z * z)

      Math.asin(cosine.clamp(-1.0, 1.0))
    end

    def sidereal_radians_at(time)
      sidereal_hours = @anchor_sidereal_hours +
        (time - @anchor) *
          Constants::HOURS_PER_DAY *
          GreenwichMeanSiderealTime::UT_TO_SIDEREAL_RATIO

      sidereal_hours * RADIANS_PER_HOUR
    end

    def place(time)
      first, second, third = interpolation_window(time)
      x0 = @node_times[first]
      x1 = @node_times[second]
      x2 = @node_times[third]
      w0 = (time - x1) * (time - x2) / ((x0 - x1) * (x0 - x2))
      w1 = (time - x0) * (time - x2) / ((x1 - x0) * (x1 - x2))
      w2 = (time - x0) * (time - x1) / ((x2 - x0) * (x2 - x1))

      [
        @node_right_ascensions,
        @node_declinations,
        @node_distances
      ].map do |values|
        values[first] * w0 + values[second] * w1 + values[third] * w2
      end
    end

    def interpolation_window(time)
      nearest = @node_times
        .each_index
        .min_by { |index| (@node_times[index] - time).abs }
      middle = nearest.clamp(1, @node_times.length - 2)

      [middle - 1, middle, middle + 1]
    end

    def horizon_crossing_times
      @memo[:horizon_crossing_times] ||= RootFinder
        .new(
          value_at: ->(time) { clearance(time) },
          period: SAMPLING_INTERVAL_IN_DAYS,
          samples_per_period: 1
        )
        .roots(@window_start, @window_end)
    end

    def within_eclipse(instant)
      time = instant.tt
      unless time.between?(@window_start, @window_end)
        raise ArgumentError,
          "the instant must be between the first and last penumbral contact"
      end

      time
    end
  end
end
