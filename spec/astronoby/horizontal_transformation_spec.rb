# frozen_string_literal: true

RSpec.describe Astronoby::HorizontalTransformation do
  describe "#apply" do
    it "matches the reference frame chain of a deep-sky object" do
      instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      stars = [
        # Sirius
        [Astronoby::Angle.from_hms(6, 45, 8.917),
          Astronoby::Angle.from_dms(-16, 42, 58.02)],
        # Vega
        [Astronoby::Angle.from_hms(18, 36, 56.336),
          Astronoby::Angle.from_dms(38, 47, 1.28)],
        # Polaris
        [Astronoby::Angle.from_hms(2, 31, 49.09),
          Astronoby::Angle.from_dms(89, 15, 50.8)],
        # Acrux, which is below the horizon
        [Astronoby::Angle.from_hms(12, 26, 35.9),
          Astronoby::Angle.from_dms(-63, 5, 56.7)]
      ]
      transformation = described_class.new(observer: observer, instant: instant)

      stars.each do |right_ascension, declination|
        equatorial = Astronoby::Coordinates::Equatorial.new(
          right_ascension: right_ascension,
          declination: declination
        )

        horizontal = transformation.apply(equatorial)
        expected = Astronoby::DeepSkyObject
          .new(equatorial_coordinates: equatorial)
          .at(instant)
          .observed_by(observer)
          .horizontal

        expect(horizontal.altitude.degrees)
          .to be_within(1e-9).of(expected.altitude.degrees)
        expect(horizontal.azimuth.degrees)
          .to be_within(1e-9).of(expected.azimuth.degrees)
      end
    end

    it "matches the reference frame chain in the southern hemisphere" do
      instant = Astronoby::Instant.from_time(Time.utc(2001, 3, 14, 3, 15, 9))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(-33.8688),
        longitude: Astronoby::Angle.from_degrees(151.2093)
      )
      equatorial = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(14, 39, 36.5),
        declination: Astronoby::Angle.from_dms(-60, 50, 2.3)
      )

      horizontal = described_class
        .new(observer: observer, instant: instant)
        .apply(equatorial)
      expected = Astronoby::DeepSkyObject
        .new(equatorial_coordinates: equatorial)
        .at(instant)
        .observed_by(observer)
        .horizontal

      expect(horizontal.altitude.degrees)
        .to be_within(1e-9).of(expected.altitude.degrees)
      expect(horizontal.azimuth.degrees)
        .to be_within(1e-9).of(expected.azimuth.degrees)
    end

    it "returns horizontal coordinates for the observer" do
      instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      equatorial = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
        declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
      )

      horizontal = described_class
        .new(observer: observer, instant: instant)
        .apply(equatorial)

      expect(horizontal).to be_a(Astronoby::Coordinates::Horizontal)
      expect(horizontal.observer).to eq(observer)
    end

    it "ignores the hour angle of the given coordinates" do
      instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      transformation = described_class.new(observer: observer, instant: instant)
      equatorial = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
        declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
      )
      with_hour_angle = Astronoby::Coordinates::Equatorial.new(
        right_ascension: equatorial.right_ascension,
        declination: equatorial.declination,
        hour_angle: Astronoby::Angle.from_hours(3)
      )

      expect(transformation.apply(with_hour_angle).altitude)
        .to eq(transformation.apply(equatorial).altitude)
    end

    context "with refraction" do
      it "matches the refracted coordinates of the reference frame chain" do
        instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 25, 2))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        # Sirius, about 2.6 degrees above the horizon
        equatorial = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
          declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
        )

        horizontal = described_class
          .new(observer: observer, instant: instant)
          .apply(equatorial, refraction: true)
        expected = Astronoby::DeepSkyObject
          .new(equatorial_coordinates: equatorial)
          .at(instant)
          .observed_by(observer)
          .horizontal(refraction: true)

        expect(horizontal.altitude.degrees)
          .to be_within(1e-9).of(expected.altitude.degrees)
        expect(horizontal.azimuth.degrees)
          .to be_within(1e-9).of(expected.azimuth.degrees)
      end

      it "raises the altitude of a body close to the horizon" do
        instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 25, 2))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        transformation = described_class
          .new(observer: observer, instant: instant)
        equatorial = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
          declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
        )

        refracted = transformation.apply(equatorial, refraction: true)
        unrefracted = transformation.apply(equatorial)

        expect(refracted.altitude).to be > unrefracted.altitude
      end
    end

    context "when the coordinates are not at epoch J2000.0" do
      it "raises an error" do
        instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        transformation = described_class
          .new(observer: observer, instant: instant)
        of_date = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
          declination: Astronoby::Angle.from_dms(-16, 42, 58.02),
          epoch: instant.tt
        )

        expect { transformation.apply(of_date) }
          .to raise_error(Astronoby::IncompatibleArgumentsError, /J2000/)
      end
    end
  end

  describe "#observer" do
    it "returns the observer" do
      instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )

      transformation = described_class
        .new(observer: observer, instant: instant)

      expect(transformation.observer).to eq(observer)
    end
  end

  describe "#instant" do
    it "returns the instant" do
      instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )

      transformation = described_class
        .new(observer: observer, instant: instant)

      expect(transformation.instant).to eq(instant)
    end
  end

  it "is frozen" do
    instant = Astronoby::Instant.from_time(Time.utc(2026, 9, 24, 22))
    observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.8566),
      longitude: Astronoby::Angle.from_degrees(2.3522)
    )

    transformation = described_class.new(observer: observer, instant: instant)

    expect(transformation).to be_frozen
  end
end
