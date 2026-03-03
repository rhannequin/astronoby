# frozen_string_literal: true

module Astronoby
  # Holds arrays of rising, transit, and setting times over a time range.
  class RiseTransitSetEvents
    # @return [Array<Time>] rising times
    attr_reader :rising_times

    # @return [Array<Time>] transit (culmination) times
    attr_reader :transit_times

    # @return [Array<Time>] setting times
    attr_reader :setting_times

    # @param risings [Array<Time>] rising times
    # @param transits [Array<Time>] transit times
    # @param settings [Array<Time>] setting times
    def initialize(risings, transits, settings)
      @rising_times = risings
      @transit_times = transits
      @setting_times = settings
    end
  end
end
