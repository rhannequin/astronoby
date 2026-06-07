# frozen_string_literal: true

module Astronoby
  # Geocentric libration of the Moon: the small oscillations that let an
  # observer on Earth see slightly more than half of the lunar surface over
  # time. Holds the total (optical + physical) libration in longitude and
  # latitude.
  class Libration
    # @return [Astronoby::Angle] libration in longitude (l), positive towards
    #   the Moon's Mare Crisium (east limb)
    attr_reader :longitude

    # @return [Astronoby::Angle] libration in latitude (b), positive towards
    #   the Moon's north pole
    attr_reader :latitude

    # @param longitude [Astronoby::Angle] libration in longitude
    # @param latitude [Astronoby::Angle] libration in latitude
    def initialize(longitude:, latitude:)
      @longitude = longitude
      @latitude = latitude
      freeze
    end
  end
end
