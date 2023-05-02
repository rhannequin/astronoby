# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")

      expect(
        described_class.new(
          right_ascension: Astronoby::Angle.as_hours(BigDecimal("23.9994")),
          declination: Astronoby::Angle.as_degrees(BigDecimal("-89.9997"))
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      ).to be_an_instance_of(Astronoby::Coordinates::Horizontal)
    end

    context "with real life arguments (Venus, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 30, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("341.55600329524782")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("-73.45532158193984")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_hours(
            BigDecimal("17.731666666666667")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("-22.166666666666667")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Betelgeuse, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("171.08405974991367")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("59.21671281430846")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_hours(
            BigDecimal("5.916090944444444")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("7.498241083333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        time = Time.new(2022, 12, 8, 6, 22, 33, "+01:00")
        latitude = BigDecimal("39.46975")
        longitude = BigDecimal("-0.377389")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("285.64541526536471")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("21.03703466806004")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_hours(BigDecimal("4.97602775")),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("24.992300833333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Mars, from Paris, France)" do
      it "computes properly" do
        time = Time.utc(2022, 12, 6, 23, 48, 0)
        latitude = BigDecimal("48.854419")
        longitude = BigDecimal("2.482681")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_hours(BigDecimal("5.0109194444")),
          declination: Astronoby::Angle.as_degrees(BigDecimal("24.99463888"))
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("+66° 8′ 24.6201″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("+180° 8′ 10.6833″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2015, 12, 1, 9, 0, 0, "-08:00")
        latitude = 45
        longitude = -100

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_hours(6),
          declination: Astronoby::Angle.as_degrees(-60)
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("-59° 41′ 58.4873″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("+224° 15′ 26.7332″")
        )
      end
    end
  end

  describe "#to_ecliptic" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    context "with real life arguments (book example)" do
      it "computes properly" do
        right_ascension = Astronoby::Angle.as_degrees(BigDecimal("11.17027"))
        declination = Astronoby::Angle.as_degrees(BigDecimal("30.09444"))
        epoch = Astronoby::Epoch::J2000

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.to_dms.format).to(
          eq("+22° 41′ 53.7254″")
        )
        expect(ecliptic_coordinates.longitude.to_dms.format).to(
          eq("+156° 19′ 8.6097″")
        )
      end
    end
  end
end
