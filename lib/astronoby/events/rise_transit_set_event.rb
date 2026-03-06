# frozen_string_literal: true

module Astronoby
  # Holds the rising, transit, and setting times for a single day.
  class RiseTransitSetEvent
    # @return [Time, nil] the rising time
    attr_reader :rising_time

    # @return [Time, nil] the transit (culmination) time
    attr_reader :transit_time

    # @return [Time, nil] the setting time
    attr_reader :setting_time

    # @param rising [Time, nil] the rising time
    # @param transit [Time, nil] the transit time
    # @param setting [Time, nil] the setting time
    def initialize(rising, transit, setting)
      @rising_time = rising
      @transit_time = transit
      @setting_time = setting
    end
  end
end
