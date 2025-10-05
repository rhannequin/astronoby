# frozen_string_literal: true

RSpec.describe Astronoby::Events::MoonPhases do
  it "returns a list of Moon phases" do
    expect(described_class.phases_for(year: 2024, month: 1))
      .to all(be_a(Astronoby::MoonPhase))
  end

  it "returns the phases for a given year and month: January 2024" do
    moon_phases = described_class.phases_for(year: 2024, month: 1)

    expect(moon_phases[0].phase).to eq(:last_quarter)
    expect(moon_phases[0].time).to eq(Time.utc(2024, 1, 4, 3, 30, 26))
    # Result from IMCCE: 2024-01-04T03:30:27Z

    expect(moon_phases[1].phase).to eq(:new_moon)
    expect(moon_phases[1].time).to eq(Time.utc(2024, 1, 11, 11, 57, 23))
    # Result from IMCCE: 2024-01-11T11:57:25Z

    expect(moon_phases[2].phase).to eq(:first_quarter)
    expect(moon_phases[2].time).to eq(Time.utc(2024, 1, 18, 3, 52, 37))
    # Result from IMCCE: 2024-01-18T03:52:37Z

    expect(moon_phases[3].phase).to eq(:full_moon)
    expect(moon_phases[3].time).to eq(Time.utc(2024, 1, 25, 17, 54, 1))
    # Result from IMCCE: 2024-01-25T17:54:01Z
  end

  it "returns correct phase events for 2025-08" do
    moon_phases = described_class.phases_for(year: 2025, month: 8)
    days_of_moon_phases = moon_phases.map { _1.time.day }

    # Phases in August 2025 from IMCCE (days): 1, 9, 16, 23, 31
    expect(days_of_moon_phases).to eq([1, 9, 16, 23, 31])
  end

  context "when there are more than 4 phases in a month" do
    it "returns all of them" do
      moon_phases = described_class.phases_for(year: 2024, month: 5)

      expect(moon_phases[0].phase).to eq(:last_quarter)
      expect(moon_phases[0].time).to eq(Time.utc(2024, 5, 1, 11, 27, 15))
      # Result from IMCCE: 2024-05-01T11:27:17Z

      expect(moon_phases[1].phase).to eq(:new_moon)
      expect(moon_phases[1].time).to eq(Time.utc(2024, 5, 8, 3, 21, 56))
      # Result from IMCCE: 2024-05-08T03:21:56Z

      expect(moon_phases[2].phase).to eq(:first_quarter)
      expect(moon_phases[2].time).to eq(Time.utc(2024, 5, 15, 11, 48, 2))
      # Result from IMCCE: 2024-05-15T11:48:00Z

      expect(moon_phases[3].phase).to eq(:full_moon)
      expect(moon_phases[3].time).to eq(Time.utc(2024, 5, 23, 13, 53, 12))
      # Result from IMCCE: 2024-05-23T13:53:09Z

      expect(moon_phases[4].phase).to eq(:last_quarter)
      expect(moon_phases[4].time).to eq(Time.utc(2024, 5, 30, 17, 12, 42))
      # Result from IMCCE: 2024-05-30T17:12:40Z
    end
  end
end
