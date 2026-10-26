# frozen_string_literal: true

RSpec.describe Astronoby::AltitudeCrossingCalculator do
  include TestEphemHelper

  describe "#initialize" do
    it "raises when the body cannot be positioned" do
      expect {
        described_class.new(body: Object, observer: paris, ephem: nil)
      }.to raise_error(Astronoby::IncompatibleArgumentsError)
    end

    it "raises when the reference is unknown" do
      expect {
        sun_calculator(paris, reference: :edge)
      }.to raise_error(Astronoby::IncompatibleArgumentsError)
    end
  end

  describe "#crossings_between" do
    it "finds the twilight crossings of a day, unrounded and in order" do
      calculator = sun_calculator(paris)

      crossings = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.from_degrees(-18)
      )

      expect(crossings.map(&:direction)).to eq [:rising, :setting]
      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 10, 23, 4, 37, 28),
          Time.utc(2026, 10, 23, 18, 31, 29)
        ]
      expect(crossings.map(&:grazing?)).to eq [false, false]
      # IMCCE:    04:37:27 and 18:31:29
      #           The morning one is 0.6 s off, INPOP19A against DE440s
      # Horizons: 04:37:27.560 and 18:31:29.102
      # Skyfield: 04:37:27.447 and 18:31:28.989
    end

    it "agrees with USNO, Horizons and Skyfield on the civil twilight" do
      calculator = sun_calculator(paris)

      crossings = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.from_degrees(-6)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 10, 23, 5, 50, 49),
          Time.utc(2026, 10, 23, 17, 18, 16)
        ]
      # USNO:     05:51 and 17:18, to the minute
      # Horizons: 05:50:48.876 and 17:18:16.110
      # Skyfield: 05:50:48.764 and 17:18:15.997
    end

    it "agrees with IMCCE on the nautical twilight in Paris" do
      calculator = sun_calculator(paris)

      crossing = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.from_degrees(-12)
      ).first

      expect(crossing.instant.to_time.round)
        .to eq Time.utc(2026, 10, 23, 5, 14, 0)
      # IMCCE:    05:14:00
      # Horizons: 05:13:59.782
      # Skyfield: 05:13:59.669
    end

    it "agrees with IMCCE on the astronomical twilight in Makkah" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(21.4225),
        longitude: Astronoby::Angle.from_degrees(39.8262)
      )
      calculator = sun_calculator(observer)

      crossings = calculator.crossings_between(
        Time.utc(2026, 3, 20),
        Time.utc(2026, 3, 21),
        altitude: Astronoby::Angle.from_degrees(-18)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 3, 20, 2, 11, 3),
          Time.utc(2026, 3, 20, 16, 45, 40)
        ]
      # IMCCE:    02:11:03 and 16:45:40
      # Horizons: 02:11:03.360 and 16:45:39.935
      # Skyfield: 02:11:03.375 and 16:45:39.950
    end

    it "agrees with IMCCE on the astronomical twilight at 60°N in winter" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(60),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)

      crossings = calculator.crossings_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22),
        altitude: Astronoby::Angle.from_degrees(-18)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 12, 21, 5, 35, 40),
          Time.utc(2026, 12, 21, 17, 0, 26)
        ]
      # IMCCE:    05:35:40 and 17:00:26
      # Horizons: 05:35:39.937 and 17:00:25.547
      # Skyfield: 05:35:39.798 and 17:00:25.407
    end

    it "agrees with IMCCE on the astronomical twilight in a polar night" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(75),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)

      crossings = calculator.crossings_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22),
        altitude: Astronoby::Angle.from_degrees(-18)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 12, 21, 6, 31, 48),
          Time.utc(2026, 12, 21, 16, 4, 17)
        ]
      # IMCCE:    06:31:48 and 16:04:17
      # Horizons: 06:31:47.653 and 16:04:17.152
      # Skyfield: 06:31:47.562 and 16:04:17.062
    end

    # IMCCE has no custom angles, so these values are this calculator's own
    # output, not an external reference.
    it "accepts an altitude that no other service offers" do
      calculator = sun_calculator(paris)

      crossings = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.from_degrees(-17.5)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 10, 23, 4, 40, 30),
          Time.utc(2026, 10, 23, 18, 28, 27)
        ]
    end

    it "lands on the requested altitude" do
      calculator = sun_calculator(paris)
      target = Astronoby::Angle.from_degrees(-12)

      crossing = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: target
      ).first

      altitude = Astronoby::Sun
        .at(crossing.instant, ephem: test_ephem_sun)
        .observed_by(paris)
        .horizontal
        .altitude
      expect(altitude.degrees.round(4)).to eq(-12.0)
    end

    it "finds crossings in a polar night" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(75),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)

      crossings = calculator.crossings_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22),
        altitude: Astronoby::Angle.from_degrees(-12)
      )

      expect(crossings.map { |crossing| crossing.instant.to_time.round })
        .to eq [
          Time.utc(2026, 12, 21, 8, 29, 45),
          Time.utc(2026, 12, 21, 14, 6, 20)
        ]
      # IMCCE:    08:29:45 and 14:06:20
      # Horizons: 08:29:45.310 and 14:06:19.653
      # Skyfield: 08:29:45.220 and 14:06:19.563
    end

    it "returns nothing when the body never reaches the altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(75),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)

      crossings = calculator.crossings_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22),
        altitude: Astronoby::Angle.zero
      )

      expect(crossings).to be_empty
    end

    it "flags a crossing whose target is barely reached" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(75),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)
      highest = calculator.extremes_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22)
      ).find { |extreme| extreme.kind == :upper_culmination }

      crossings = calculator.crossings_between(
        Time.utc(2026, 12, 21),
        Time.utc(2026, 12, 22),
        altitude: highest.altitude - Astronoby::Angle.from_degrees(0.01)
      )

      expect(crossings.map(&:direction)).to eq [:rising, :setting]
      expect(crossings.map(&:grazing?)).to eq [true, true]
    end

    it "uses the upper limb of the Sun" do
      calculator = sun_calculator(paris, reference: :upper_limb)

      crossing = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.zero
      ).first

      # Sunrise for the upper limb, a bit before the centre reaches 0°
      center = sun_calculator(paris).crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: Astronoby::Angle.zero
      ).first
      expect(crossing.instant).to be < center.instant
    end

    it "raises when the window ends before it starts" do
      calculator = sun_calculator(paris)

      expect {
        calculator.crossings_between(
          Time.utc(2026, 10, 24),
          Time.utc(2026, 10, 23),
          altitude: Astronoby::Angle.zero
        )
      }.to raise_error(Astronoby::IncompatibleArgumentsError)
    end
  end

  describe "#multiple_crossings_between" do
    it "returns the same crossings as one call per altitude" do
      calculator = sun_calculator(paris)
      start_time = Time.utc(2026, 10, 23)
      end_time = Time.utc(2026, 10, 24)
      altitudes = [-6, -12, -18].map { Astronoby::Angle.from_degrees(_1) }

      together = calculator.multiple_crossings_between(
        start_time, end_time, altitudes: altitudes
      )
      separately = altitudes.map do |altitude|
        calculator.crossings_between(start_time, end_time, altitude: altitude)
      end

      expect(together.map { |c| c.map { _1.instant.tt } })
        .to eq separately.map { |c| c.map { _1.instant.tt } }
    end
  end

  describe "#crossing_on" do
    it "returns the crossing of the asked direction on a local day" do
      calculator = sun_calculator(paris)

      crossing = calculator.crossing_on(
        Date.new(2026, 10, 23),
        altitude: Astronoby::Angle.from_degrees(-17.5),
        direction: :setting,
        utc_offset: "+02:00"
      )

      expect(crossing).to be_a(Astronoby::AltitudeCrossing)
      expect(crossing.instant.to_time.round)
        .to eq Time.utc(2026, 10, 23, 18, 28, 27)
    end

    it "agrees with the window of the day, up to the next midnight" do
      calculator = sun_calculator(paris)
      altitude = Astronoby::Angle.from_degrees(-12)

      crossing = calculator.crossing_on(
        Date.new(2026, 10, 23),
        altitude: altitude,
        direction: :rising
      )
      in_window = calculator.crossings_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24),
        altitude: altitude
      ).find { _1.direction == :rising }

      expect(crossing.instant).to eq in_window.instant
    end

    it "returns nil when there is no such crossing" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(75),
        longitude: Astronoby::Angle.from_degrees(10)
      )
      calculator = sun_calculator(observer)

      crossing = calculator.crossing_on(
        Date.new(2026, 12, 21),
        altitude: Astronoby::Angle.zero,
        direction: :rising
      )

      expect(crossing).to be_nil
    end

    it "raises when the direction is unknown" do
      calculator = sun_calculator(paris)

      expect {
        calculator.crossing_on(
          Date.new(2026, 10, 23),
          altitude: Astronoby::Angle.zero,
          direction: :up
        )
      }.to raise_error(Astronoby::IncompatibleArgumentsError)
    end
  end

  describe "#extremes_between" do
    it "returns the culminations with their altitudes" do
      calculator = sun_calculator(paris)

      extremes = calculator.extremes_between(
        Time.utc(2026, 10, 23),
        Time.utc(2026, 10, 24)
      )

      expect(extremes.map(&:kind))
        .to eq [:upper_culmination, :lower_culmination]
      upper = extremes.first
      expect(upper.instant.to_time.hour).to eq 11
      expect(upper.altitude.degrees.round(2)).to eq 29.64
      expect(extremes.last.altitude).to be < Astronoby::Angle.zero
    end
  end

  def paris
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.8575),
      longitude: Astronoby::Angle.from_degrees(2.3514)
    )
  end

  def sun_calculator(observer, **options)
    described_class.new(
      body: Astronoby::Sun,
      observer: observer,
      ephem: test_ephem_sun,
      **options
    )
  end
end
