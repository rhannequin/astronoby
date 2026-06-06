# frozen_string_literal: true

RSpec.describe Astronoby::Position do
  include TestEphemHelper

  it "is fulfilled by solar system body instances" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))

    saturn = Astronoby::Saturn.new(instant: instant, ephem: test_ephem)

    expect(saturn).to be_a(described_class)
  end

  it "is fulfilled by deep-sky object positions" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))

    position = deep_sky_object.at(instant)

    expect(position).to be_a(described_class)
  end

  describe "#body" do
    it "is the class for a solar system body" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))

      saturn = Astronoby::Saturn.new(instant: instant, ephem: test_ephem)

      expect(saturn.body).to eq(Astronoby::Saturn)
    end

    it "is the definition for a deep-sky object" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))
      object = deep_sky_object

      position = object.at(instant)

      expect(position.body).to be(object)
    end
  end

  describe "#observed_by" do
    it "carries the body as the frame's target body" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))
      saturn = Astronoby::Saturn.new(instant: instant, ephem: test_ephem)

      topocentric = saturn.observed_by(observer)

      expect(topocentric.target_body).to eq(Astronoby::Saturn)
    end
  end

  it "exposes a Body as the target body on every frame of the chain" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))
    saturn = Astronoby::Saturn.new(instant: instant, ephem: test_ephem)

    frames = [
      saturn.geometric,
      saturn.astrometric,
      saturn.mean_of_date,
      saturn.apparent,
      saturn.observed_by(observer)
    ]

    frames.each do |frame|
      expect(frame.target_body).to be_a(Astronoby::Body)
    end
  end

  def deep_sky_object
    Astronoby::DeepSkyObject.new(
      equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(16, 29, 24.46),
        declination: Astronoby::Angle.from_dms(-26, 25, 55.2)
      )
    )
  end

  def observer
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.8566),
      longitude: Astronoby::Angle.from_degrees(2.3522)
    )
  end
end
