# frozen_string_literal: true

RSpec.describe Astronoby::Instant do
  describe ".new / .from_terrestrial_time" do
    it "creates an instance of Astronoby::Instant" do
      instant = described_class.new(2451545.0)

      expect(instant).to be_a(Astronoby::Instant)
    end

    it "creates an instance from a terrestrial time" do
      terrestrial_time = 2451545.0

      instant = described_class.new(terrestrial_time)

      expect(instant.terrestrial_time).to eq(terrestrial_time)
    end

    context "when the argument is not a Numeric" do
      it "raises an ArgumentError" do
        expect {
          described_class.new("2451545.0")
        }.to raise_error(
          Astronoby::UnsupportedFormatError,
          "terrestrial_time must be a Numeric"
        )
      end
    end
  end

  describe ".from_time" do
    it "creates an instance of Astronoby::Instant" do
      instant = described_class.from_time(Time.new)

      expect(instant).to be_a(Astronoby::Instant)
    end

    it "handles the difference delta-t = TT - UT" do
      time = Time.utc(2025, 1, 1)

      instant = described_class.from_time(time)

      expect(instant.terrestrial_time).to eq(70867483223/28800r)
      # 2460676.500798611
    end

    it "handles time zones" do
      time = Time.new(2025, 1, 1, 0, 0, 0, "-05:00")

      instant = described_class.from_time(time)

      expect(instant.terrestrial_time).to eq(70867489223/28800r)
      # 2460676.7091319445
    end
  end

  describe ".from_utc_julian_date" do
    it "creates an instance of Astronoby::Instant" do
      instant = described_class.from_utc_julian_date(2451545.0)

      expect(instant).to be_a(Astronoby::Instant)
    end

    it "handles the difference delta-t = TT - UT" do
      time = Time.utc(2025, 1, 1)
      julian_date = Astronoby::Epoch.from_time(time)

      instant = described_class.from_utc_julian_date(julian_date)

      expect(instant.terrestrial_time).to eq(70867483223/28800r)
      # 2460676.500798611
    end
  end

  describe "#diff" do
    it "returns the difference between two instances" do
      instant1 = described_class.new(2451545.0)
      instant2 = described_class.new(2451546.0)

      expect(instant1.diff(instant2)).to eq(-1.0)
    end
  end

  describe "#tai" do
    it "returns the International Atomic Time" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.tai.to_f).to eq(2460676.5004261113)
    end
  end

  describe "#utc_offset" do
    it "returns the difference between the instance and the UTC time" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.utc_offset).to eq(23/28800r)
      # 0.0007986111111111112
    end
  end

  describe "#gmst" do
    it "returns the Greenwich Mean Sidereal Time" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.gmst).to eq(6.7266376305619815)
    end
  end

  describe "#delta_t" do
    it "returns the difference delta-t = TT - UT" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.delta_t).to eq(69)
    end
  end

  describe "#to_datetime" do
    it "returns a DateTime instance" do
      instant = described_class.new(2451545.0)

      expect(instant.to_datetime).to be_a(DateTime)
    end

    it "returns the correct DateTime" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.to_datetime).to eq(DateTime.new(2025, 1, 1, 0, 0, 0))
    end
  end

  describe "#to_date" do
    it "returns a Date instance" do
      instant = described_class.new(2451545.0)

      expect(instant.to_date).to be_a(Date)
    end

    it "returns the correct Date" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.to_date).to eq(Date.new(2025, 1, 1))
    end
  end

  describe "#to_time" do
    it "returns a Time instance" do
      instant = described_class.new(2451545.0)

      expect(instant.to_time).to be_a(Time)
    end

    it "returns the correct Time" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant.to_time).to eq(Time.utc(2025, 1, 1))
    end
  end

  describe "equivalence (#==)" do
    it "returns true when the instant is equivalent" do
      instant1 = described_class.from_time(Time.utc(2025, 1, 1))
      instant2 = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant1).to eq instant2
    end

    it "returns false when the instant is not equivalent" do
      instant1 = described_class.from_time(Time.utc(2025, 1, 1))
      instant2 = described_class.from_time(Time.utc(2024, 1, 1))

      expect(instant1).not_to eq instant2
    end
  end

  describe "hash equality" do
    it "makes an instant foundable as a Hash key" do
      instant1 = described_class.from_time(Time.utc(2025, 1, 1))
      instant1_bis = described_class.from_time(Time.utc(2025, 1, 1))
      map = {instant1 => :instant}

      expect(map[instant1_bis]).to eq :instant
    end

    it "makes an instant foundable in a Set" do
      instant1 = described_class.from_time(Time.utc(2025, 1, 1))
      instant1_bis = described_class.from_time(Time.utc(2025, 1, 1))
      set = Set.new([instant1])

      expect(set.include?(instant1_bis)).to be true
    end
  end

  describe "comparison" do
    it "handles comparison of angles" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))
      same_instant = described_class.from_time(Time.utc(2025, 1, 1))
      future_instant = described_class.from_time(Time.utc(2025, 1, 2))
      past_instant = described_class.from_time(Time.utc(2024, 12, 31))

      expect(instant == same_instant).to be true
      expect(instant != same_instant).to be false
      expect(instant > same_instant).to be false
      expect(instant >= same_instant).to be true
      expect(instant < same_instant).to be false
      expect(instant <= same_instant).to be true

      expect(instant < future_instant).to be true
      expect(instant == future_instant).to be false
      expect(instant != future_instant).to be true
      expect(instant > future_instant).to be false

      expect(instant < past_instant).to be false
      expect(instant == past_instant).to be false
      expect(instant != past_instant).to be true
      expect(instant > past_instant).to be true
    end

    it "doesn't support comparison of angles with other types" do
      instant = described_class.from_time(Time.utc(2025, 1, 1))

      expect(instant <=> 10).to be_nil
    end
  end
end
