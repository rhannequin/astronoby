# frozen_string_literal: true

RSpec.describe Astronoby::AltitudeExtreme do
  describe "#airmass" do
    it "refracts a true altitude just below the horizon with the observer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      altitude = Astronoby::Angle.from_degrees(-0.3)
      extreme = described_class.new(
        kind: :lower_culmination,
        instant: Astronoby::Instant.from_time(Time.utc(2026, 1, 1)),
        altitude: altitude,
        observer: observer
      )

      expect(extreme.airmass).to eq Astronoby::Airmass.from_true_altitude(
        altitude,
        observer: observer
      )
      expect(extreme.airmass).not_to be_nil
    end

    it "is nil below the horizon without an observer" do
      extreme = described_class.new(
        kind: :lower_culmination,
        instant: Astronoby::Instant.from_time(Time.utc(2026, 1, 1)),
        altitude: Astronoby::Angle.from_degrees(-0.3)
      )

      expect(extreme.airmass).to be_nil
    end
  end
end
