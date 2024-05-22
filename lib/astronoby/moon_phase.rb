# frozen_string_literal: true

module Astronoby
  class MoonPhase
    NEW_MOON = :new_moon
    FIRST_QUARTER = :first_quarter
    FULL_MOON = :full_moon
    LAST_QUARTER = :last_quarter

    attr_reader :time, :phase

    # @param time [Time] Time of the Moon phase
    # @return [Astronoby::MoonPhase] New Moon phase
    def self.new_moon(time)
      new(time: time, phase: NEW_MOON)
    end

    # @param time [Time] Time of the Moon phase
    # @return [Astronoby::MoonPhase] First quarter Moon phase
    def self.first_quarter(time)
      new(time: time, phase: FIRST_QUARTER)
    end

    # @param time [Time] Time of the Moon phase
    # @return [Astronoby::MoonPhase] Full Moon phase
    def self.full_moon(time)
      new(time: time, phase: FULL_MOON)
    end

    # @param time [Time] Time of the Moon phase
    # @return [Astronoby::MoonPhase] Last quarter Moon phase
    def self.last_quarter(time)
      new(time: time, phase: LAST_QUARTER)
    end

    # @param time [Time] Time of the Moon phase
    # @param phase [Symbol] Moon phase
    def initialize(time:, phase:)
      @time = time
      @phase = phase
    end
  end
end
