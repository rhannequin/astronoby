# frozen_string_literal: true

RSpec.describe Astronoby::Correction::LightTimeDelay do
  describe "#delay" do
    it "returns the light time delay" do
      # Geometric position of Earth on date
      center = instance_double(
        Astronoby::Position::Geometric,
        position: Astronoby::Vector[
          Astronoby::Distance.from_au(-0.745519104045),
          Astronoby::Distance.from_km(0.593567726886),
          Astronoby::Distance.from_km(0.257495120158)
        ],
        instant: Astronoby::Instant.from_time(Time.utc(2025, 2, 7, 12))
      )
      # Geometric position of Neptune on date
      target = instance_double(
        Astronoby::Position::Geometric,
        position: Astronoby::Vector[
          Astronoby::Distance.from_au(29.875700436001),
          Astronoby::Distance.from_au(-0.208123819479),
          Astronoby::Distance.from_au(-0.828985063803)
        ],
        target_body: Astronoby::Neptune
      )
      ephem = double
      # Data collected from Ephem
      allow(ephem).to receive(:[]).and_return(
        double(
          compute_and_differentiate: double(
            position: double(
              x: 4469342279.707888,
              y: -31213424.580853883,
              z: -124046256.6991955
            ),
            velocity: double(x: 1, y: 2, z: 3)
          )
        ),
        double(
          compute_and_differentiate: double(
            position: double(
              x: 4469342279.707446,
              y: -31213424.61872705,
              z: -124046256.7146862
            ),
            velocity: double(x: 1, y: 2, z: 3)
          )
        ),
        double(
          compute_and_differentiate: double(
            position: double(
              x: 4469342279.707446,
              y: -31213424.61872705,
              z: -124046256.7146862
            ),
            velocity: double(x: 1, y: 2, z: 3)
          )
        )
      )

      delay = described_class.new(
        center: center,
        target: target,
        ephem: ephem
      ).delay

      delay_in_minutes = (delay / Astronoby::Constants::SECONDS_PER_MINUTE)
      expect(delay_in_minutes.round).to eq(255)
      # IMCCE light time delay: 255 minutes
    end
  end
end
