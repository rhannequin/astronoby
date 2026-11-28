# frozen_string_literal: true

module Astronoby
  module Position
    # @param observer [Astronoby::Observer] the observer
    # @return [Astronoby::Topocentric] the topocentric reference frame
    def observed_by(observer)
      Topocentric.build_from_astrometric(
        instant: instant,
        target_astrometric: astrometric,
        observer: observer,
        target_body: body,
        earth_geometric: earth_geometric,
        sun_geometric: deflecting_sun_geometric,
        target_barycentric_velocity: barycentric_velocity,
        precession_matrix: precession_matrix,
        nutation_matrix: nutation_matrix
      )
    end
  end
end
