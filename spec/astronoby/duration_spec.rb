# frozen_string_literal: true

require "set" # rubocop:disable Lint/RedundantRequireStatement

RSpec.describe Astronoby::Duration do
  describe "object immutability" do
    context "when a mutable method is added" do
      it "raises a FrozenError when immutability is broken" do
        described_class.class_eval do
          def clear
            @seconds = 0
          end
        end

        expect { described_class.from_seconds(1).clear }
          .to raise_error(FrozenError)
      end
    end
  end

  describe "::zero" do
    it "returns a Duration object" do
      expect(described_class.zero).to be_a(described_class)
    end

    it "returns a duration of zero seconds" do
      expect(described_class.zero.seconds).to eq 0
    end
  end

  describe "::from_seconds" do
    it "returns a Duration object" do
      expect(described_class.from_seconds(1)).to be_a(described_class)
    end
  end

  describe "::from_minutes" do
    it "returns a Duration object" do
      expect(described_class.from_minutes(1)).to be_a(described_class)
    end

    it "converts minutes to seconds" do
      duration = described_class.from_minutes(1)

      expect(duration.seconds).to eq 60
    end
  end

  describe "::from_hours" do
    it "returns a Duration object" do
      expect(described_class.from_hours(1)).to be_a(described_class)
    end

    it "converts hours to seconds" do
      duration = described_class.from_hours(1)

      expect(duration.seconds).to eq 3_600
    end
  end

  describe "::from_days" do
    it "returns a Duration object" do
      expect(described_class.from_days(1)).to be_a(described_class)
    end

    it "converts days to seconds" do
      duration = described_class.from_days(1)

      expect(duration.seconds).to eq 86_400
    end
  end

  describe "#seconds" do
    it "returns the duration value in seconds" do
      seconds = described_class.new(1).seconds

      expect(seconds).to eq 1
    end

    context "when the duration is initialized from minutes" do
      it "returns the duration value in seconds" do
        seconds = described_class.from_minutes(1).seconds

        expect(seconds).to eq 60
      end
    end
  end

  describe "#minutes" do
    it "returns the duration value in minutes" do
      minutes = described_class.from_minutes(1).minutes

      expect(minutes).to eq 1
    end

    context "when the duration is initialized from seconds" do
      it "returns the duration value in minutes" do
        minutes = described_class.new(90).minutes

        expect(minutes).to eq 1.5
      end
    end
  end

  describe "#hours" do
    it "returns the duration value in hours" do
      hours = described_class.from_hours(1).hours

      expect(hours).to eq 1
    end

    context "when the duration is initialized from seconds" do
      it "returns the duration value in hours" do
        hours = described_class.new(5_400).hours

        expect(hours).to eq 1.5
      end
    end
  end

  describe "#days" do
    it "returns the duration value in days" do
      days = described_class.from_days(1).days

      expect(days).to eq 1
    end

    context "when the duration is initialized from seconds" do
      it "returns the duration value in days" do
        days = described_class.new(129_600).days

        expect(days).to eq 1.5
      end
    end
  end

  describe "#+" do
    it "returns a new duration with a value of the two durations added" do
      duration_1 = described_class.from_seconds(1)
      duration_2 = described_class.from_minutes(1)

      new_duration = duration_1 + duration_2

      expect(new_duration.seconds).to eq 61
    end
  end

  describe "#-" do
    it "returns a new duration with a value of the two durations subtracted" do
      duration_1 = described_class.from_minutes(1)
      duration_2 = described_class.from_seconds(1)

      new_duration = duration_1 - duration_2

      expect(new_duration.seconds).to eq 59
    end
  end

  describe "#-@" do
    it "returns a new duration with a negative value" do
      duration = described_class.from_seconds(1)

      new_duration = -duration

      expect(new_duration.seconds).to eq(-1)
    end
  end

  describe "#abs" do
    it "returns a new duration with the absolute value" do
      duration = described_class.from_seconds(-10)

      expect(duration.abs.seconds).to eq 10
    end
  end

  describe "#positive?" do
    it "returns true when the duration is positive" do
      expect(described_class.from_seconds(1).positive?).to be true
    end

    it "returns false when the duration is negative" do
      expect(described_class.from_seconds(-1).positive?).to be false
    end

    it "returns false when the duration has a zero value" do
      expect(described_class.from_seconds(0).positive?).to be false
    end
  end

  describe "#negative?" do
    it "returns false when the duration is positive" do
      expect(described_class.from_seconds(1).negative?).to be false
    end

    it "returns true when the duration is negative" do
      expect(described_class.from_seconds(-1).negative?).to be true
    end

    it "returns false when the duration has a zero value" do
      expect(described_class.from_seconds(0).negative?).to be false
    end
  end

  describe "#zero?" do
    it "returns true when the duration has a zero value" do
      expect(described_class.from_seconds(0).zero?).to be true
    end

    it "returns false when the duration has a non-zero value" do
      expect(described_class.from_seconds(1).zero?).to be false
    end
  end

  describe "equivalence (#==)" do
    it "returns true when the durations are equal" do
      duration1 = described_class.from_seconds(1)
      duration2 = described_class.from_seconds(1)

      expect(duration1 == duration2).to be true
    end

    it "returns false when the durations are not equal" do
      duration1 = described_class.from_seconds(1)
      duration2 = described_class.from_seconds(2)

      expect(duration1 == duration2).to be false
    end

    it "returns false when the durations are not of the same type" do
      duration = described_class.from_seconds(1)

      expect(duration == 1).to be false
    end
  end

  describe "hash equality" do
    it "returns the same hash for equal durations" do
      duration1 = described_class.from_seconds(1)
      duration2 = described_class.from_seconds(1)

      expect(Set[duration1, duration2].size).to eq 1
    end

    it "returns different hashes for different durations" do
      duration1 = described_class.from_seconds(1)
      duration2 = described_class.from_seconds(2)

      expect(Set[duration1, duration2].size).to eq 2
    end
  end

  describe "comparison" do
    it "handles comparison of durations" do
      duration = described_class.from_seconds(10)
      same_duration = described_class.from_seconds(10)
      greater_duration = described_class.from_seconds(20)
      smaller_duration = described_class.from_seconds(5)
      negative_duration = described_class.from_seconds(-10)

      expect(duration == same_duration).to be true
      expect(duration != same_duration).to be false
      expect(duration > same_duration).to be false
      expect(duration >= same_duration).to be true
      expect(duration < same_duration).to be false
      expect(duration <= same_duration).to be true

      expect(duration < greater_duration).to be true
      expect(duration == greater_duration).to be false
      expect(duration != greater_duration).to be true
      expect(duration > greater_duration).to be false

      expect(duration < smaller_duration).to be false
      expect(duration == smaller_duration).to be false
      expect(duration != smaller_duration).to be true
      expect(duration > smaller_duration).to be true

      expect(duration < negative_duration).to be false
      expect(duration == negative_duration).to be false
      expect(duration != negative_duration).to be true
      expect(duration > negative_duration).to be true
    end

    it "doesn't support comparison of durations with other types" do
      duration = described_class.from_seconds(10)

      expect(duration <=> 10).to be_nil
    end
  end
end
