# frozen_string_literal: true

module Astronoby
  class MoonPhase
    NEW_MOON = :new_moon
    FIRST_QUARTER = :first_quarter
    FULL_MOON = :full_moon
    LAST_QUARTER = :last_quarter

    # @return [Symbol] +:new_moon+, +:first_quarter+, +:full_moon+ or
    #   +:last_quarter+
    attr_reader :phase

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

    # @param phase [Symbol] Moon phase
    # @param time [Time, nil] Time of the Moon phase
    # @param instant [Astronoby::Instant, nil] Instant of the Moon phase, from
    #   which the time is derived when no time is given
    def initialize(phase:, time: nil, instant: nil)
      @phase = phase
      @time = time
      @instant = instant
    end

    # @return [Time] the time of the phase, rounded to the second
    def time
      @time ||= @instant.to_time.round
    end

    # @return [Astronoby::Instant] the instant of the phase
    def instant
      @instant ||= Instant.from_time(@time)
    end
  end
end
