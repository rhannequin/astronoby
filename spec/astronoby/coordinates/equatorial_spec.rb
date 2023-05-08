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

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
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
          right_ascension: Astronoby::Angle.as_hms(17, 43, 54),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("-22.166666666666667")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_hms(5, 54, 58),
          declination: Astronoby::Angle.as_degrees(BigDecimal("7.498241083333333"))
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("+59° 13′ 0.0331″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("+171° 5′ 0.5215″")
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
          right_ascension: Astronoby::Angle.as_hms(6, 0, 0),
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
        right_ascension = Astronoby::Angle.as_hms(11, 10, 13)
        declination = Astronoby::Angle.as_degrees(BigDecimal("30.09444"))
        epoch = Astronoby::Epoch::J2000

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.to_dms.format).to(
          eq("+22° 41′ 53.8784″")
        )
        expect(ecliptic_coordinates.longitude.to_dms.format).to(
          eq("+156° 19′ 8.9669″")
        )
      end
    end
  end

  describe "#to_epoch" do
    it "returns a new instance of Astronoby::Coordinates::Equatorial" do
      coordinates = described_class.new(
        right_ascension: Astronoby::Angle.as_hms(12, 0, 0),
        declination: Astronoby::Angle.as_degrees(180),
        epoch: Astronoby::Epoch::J2000
      )

      new_coordinates = coordinates.to_epoch(Astronoby::Epoch::J1950)

      expect(new_coordinates).to(
        be_an_instance_of(Astronoby::Coordinates::Equatorial)
      )
      expect(new_coordinates.epoch).to eq(Astronoby::Epoch::J1950)
    end
  end
end
