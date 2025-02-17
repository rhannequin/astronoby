# frozen_string_literal: true

module Astronoby
  class Astrometric < ReferenceFrame
    def self.build_from_geometric(
      ephem:,
      instant:,
      target_geometric:,
      target_body:
    )
      earth_geometric = Earth.geometric(ephem: ephem, instant: instant)
      corrected_position, corrected_velocity =
        Correction::LightTimeDelay.compute(
          center: earth_geometric,
          target: target_geometric,
          ephem: ephem
        )
      Astrometric.new(
        position: corrected_position - earth_geometric.position,
        velocity: corrected_velocity - earth_geometric.velocity,
        instant: instant,
        center_identifier: Planet::EARTH,
        target_body: target_body
      )
    end
  end
end
