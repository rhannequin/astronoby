# frozen_string_literal: true

module Astronoby
  # Equinoxes and solstices, read like an {Astronoby::Events::Series} with
  # +on+, +between+ and +from+, or a year at a time with {#in}.
  class Seasons
    # The equinoxes and solstices of one year.
    class Year
      # @return [Astronoby::SeasonStart]
      attr_reader :march_equinox, :june_solstice, :september_equinox,
        :december_solstice

      # @api private
      def initialize(march_equinox:, june_solstice:, september_equinox:,
        december_solstice:)
        @march_equinox = march_equinox
        @june_solstice = june_solstice
        @september_equinox = september_equinox
        @december_solstice = december_solstice
      end

      # @return [Array<Astronoby::SeasonStart>] the four, in order
      def to_a
        [march_equinox, june_solstice, september_equinox, december_solstice]
      end
    end

    WINDOW_IN_DAYS = 365.25
    HORIZON_IN_DAYS = 100 * 365.25

    # @api private
    def initialize(ephem:)
      calculator = SeasonCalculator.new(ephem: ephem)
      @series = Events::Series.new(
        window: WINDOW_IN_DAYS,
        horizon: HORIZON_IN_DAYS,
        time_of: :instant.to_proc,
        last_tt: ephem.coverage.last
      ) do |start_instant, end_instant|
        calculator.season_starts_between(start_instant, end_instant)
      end
    end

    # @param year [Integer]
    # @return [Astronoby::Seasons::Year] the equinoxes and solstices of the
    #   year, in UTC
    def in(year)
      starts = between(Time.utc(year), Time.utc(year + 1))
      Year.new(**starts.to_h { |start| [start.kind, start] })
    end

    # @see Astronoby::Events::Series#between
    def between(start_time, end_time)
      @series.between(start_time, end_time)
    end

    # @see Astronoby::Events::Series#on
    def on(date, utc_offset: 0)
      @series.on(date, utc_offset: utc_offset)
    end

    # @see Astronoby::Events::Series#from
    def from(start_time)
      @series.from(start_time)
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
