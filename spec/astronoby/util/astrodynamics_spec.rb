# frozen_string_literal: true

RSpec.describe Astronoby::Util::Astrodynamics do
  describe "::eccentric_anomaly_newton_raphson" do
    it "returns an angle" do
      mean_anomaly = Astronoby::Angle.from_radians(0.431845)
      orbital_eccentricity = 0.5
      precision = 2e-06
      iterations = 10

      solution = described_class.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity,
        precision,
        iterations
      )

      expect(solution).to be_a(Astronoby::Angle)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "computes and returns an approximate solution" do
      mean_anomaly = Astronoby::Angle.from_radians(0.431845)
      orbital_eccentricity = 0.5
      precision = 2e-06
      iterations = 10

      solution = described_class.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity,
        precision,
        iterations
      )

      expect(solution.radians).to be_within(precision).of(0.78539851485077)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "computes and returns an approximate solution" do
      mean_anomaly = Astronoby::Angle.from_degrees(5.498078)
      orbital_eccentricity = 0.00035
      precision = 2e-06
      iterations = 10

      solution = described_class.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity,
        precision,
        iterations
      )

      expect(solution.degrees).to be_within(precision).of(5.5)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "computes and returns an approximate solution" do
      mean_anomaly = Astronoby::Angle.from_degrees(5.498078)
      orbital_eccentricity = 0.6813025
      precision = 2e-06
      iterations = 10

      solution = described_class.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity,
        precision,
        iterations
      )

      expect(solution.degrees).to be_within(precision).of(16.744355)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "computes and returns an approximate solution" do
      mean_anomaly = Astronoby::Angle.from_degrees(5.498078)
      orbital_eccentricity = 0.85
      precision = 2e-06
      iterations = 10

      solution = described_class.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity,
        precision,
        iterations
      )

      expect(solution.degrees).to be_within(precision).of(29.422286)
    end
  end
end
