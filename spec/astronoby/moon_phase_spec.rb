# frozen_string_literal: true

RSpec.describe Astronoby::MoonPhase do
  describe "::new_moon" do
    it "returns a new Moon phase" do
      time = Time.new
      moon_phase = described_class.new_moon(time)

      expect(moon_phase.phase).to eq(described_class::NEW_MOON)
      expect(moon_phase.time).to eq(time)
    end
  end

  describe "::first_quarter" do
    it "returns a first quarter Moon phase" do
      time = Time.new
      moon_phase = described_class.first_quarter(time)

      expect(moon_phase.phase).to eq(described_class::FIRST_QUARTER)
      expect(moon_phase.time).to eq(time)
    end
  end

  describe "::full_moon" do
    it "returns a full Moon phase" do
      time = Time.new
      moon_phase = described_class.full_moon(time)

      expect(moon_phase.phase).to eq(described_class::FULL_MOON)
      expect(moon_phase.time).to eq(time)
    end
  end

  describe "::last_quarter" do
    it "returns a last quarter Moon phase" do
      time = Time.new
      moon_phase = described_class.last_quarter(time)

      expect(moon_phase.phase).to eq(described_class::LAST_QUARTER)
      expect(moon_phase.time).to eq(time)
    end
  end
end
