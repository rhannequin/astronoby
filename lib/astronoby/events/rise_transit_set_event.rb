# frozen_string_literal: true

module Astronoby
  class RiseTransitSetEvent
    attr_reader :rising_time, :transit_time, :setting_time

    def initialize(rising, transit, setting)
      @rising_time = rising
      @transit_time = transit
      @setting_time = setting
    end
  end
end
