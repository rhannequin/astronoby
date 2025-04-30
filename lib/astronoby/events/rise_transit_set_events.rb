# frozen_string_literal: true

module Astronoby
  class RiseTransitSetEvents
    attr_reader :rising_times, :transit_times, :setting_times

    def initialize(risings, transits, settings)
      @rising_times = risings
      @transit_times = transits
      @setting_times = settings
    end
  end
end
