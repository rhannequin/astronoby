# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")

      expect(
        described_class.new(
          right_ascension: Astronoby::Angle.as_dms(23, 59, 59),
          declination: Astronoby::Angle.as_dms(89, 59, 59)
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

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_hms(17, 43, 54),
          declination: Astronoby::Angle.as_dms(-22, 10, 0)
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("-73° 27′ 19.1576″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("+341° 33′ 21.6118″")
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
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_hms(5, 54, 58),
          declination: Astronoby::Angle.as_dms(7, 29, 54)
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("+59° 13′ 0.3626″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("+171° 5′ 0.4416″")
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
        declination = Astronoby::Angle.as_dms(30, 5, 40)
        epoch = Astronoby::Epoch::J2000

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.to_dms.format).to(
          eq("+22° 41′ 53.8929″")
        )
        expect(ecliptic_coordinates.longitude.to_dms.format).to(
          eq("+156° 19′ 8.9596″")
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
