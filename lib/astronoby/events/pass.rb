# frozen_string_literal: true

module Astronoby
  # One passage of a body across the observer's meridian, with the rising
  # before it and the setting after it.
  class Pass
    # @return [Astronoby::Instant, nil] when the body rises, nil when it does
    #   not rise since the previous transit or rises outside the ephemeris
    attr_reader :rising

    # @return [Astronoby::Instant] when the body crosses the meridian
    attr_reader :transit

    # @return [Astronoby::Instant, nil] when the body sets, nil when it does
    #   not set before the next transit or sets outside the ephemeris
    attr_reader :setting

    # @param rising [Astronoby::Instant, nil]
    # @param transit [Astronoby::Instant]
    # @param setting [Astronoby::Instant, nil]
    def initialize(rising:, transit:, setting:)
      @rising = rising
      @transit = transit
      @setting = setting
    end
  end
end
