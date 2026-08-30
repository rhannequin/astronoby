# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipseCalculator do
  include TestEphemHelper

  describe "#events_between" do
    it "carries the Moon's apparent place at every contact" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      eclipse = calculator.events_between(
        Time.utc(2025, 3, 1),
        Time.utc(2025, 4, 1)
      ).first

      contacts = [
        [eclipse.instant, eclipse.geometry],
        [
          eclipse.penumbral.starting_instant,
          eclipse.penumbral.starting_geometry
        ],
        [eclipse.partial.starting_instant, eclipse.partial.starting_geometry],
        [eclipse.total.ending_instant, eclipse.total.ending_geometry],
        [eclipse.penumbral.ending_instant, eclipse.penumbral.ending_geometry]
      ]

      contacts.each do |instant, geometry|
        apparent = Astronoby::Moon
          .new(ephem: ephem, instant: instant)
          .apparent
          .equatorial

        expect(geometry.moon_coordinates.right_ascension.degrees)
          .to be_within(1e-5).of(apparent.right_ascension.degrees)
        expect(geometry.moon_coordinates.declination.degrees)
          .to be_within(1e-5).of(apparent.declination.degrees)
        expect(geometry.moon_coordinates.epoch)
          .to be_within(1e-6).of(instant.tt)
      end
    end

    it "finds and fully describes the 2025-03-14 total lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 3, 1),
        Time.utc(2025, 4, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_total
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 6, 58, 47))
      # IMCCE: 2025-03-14T06:58:47Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(1.17865)
      # IMCCE: 1.17874

      expect(eclipse.penumbral.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 3, 57, 29))
      # IMCCE: 2025-03-14T03:57:29Z (P1)
      expect(eclipse.partial.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 5, 9, 36))
      # IMCCE: 2025-03-14T05:09:36Z (U1)
      expect(eclipse.total.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 6, 26, 3))
      # IMCCE: 2025-03-14T06:26:02Z (U2)
      expect(eclipse.total.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 7, 31, 30))
      # IMCCE: 2025-03-14T07:31:30Z (U3)
      expect(eclipse.partial.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 8, 47, 56))
      # IMCCE: 2025-03-14T08:47:55Z (U4)
      expect(eclipse.penumbral.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 10, 0, 9))
      # IMCCE: 2025-03-14T10:00:09Z (P2)
    end

    it "finds the 2025-09-07 total lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 8, 1),
        Time.utc(2025, 10, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_total
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2025, 9, 7, 18, 11, 49))
      # IMCCE: 2025-09-07T18:11:49Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(1.36202)
      # IMCCE: 1.36214
    end

    it "finds and classifies the 2024-09-18 partial lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2024, 9, 1),
        Time.utc(2024, 10, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_partial
      expect(eclipse.total).to be_nil
      expect(eclipse.partial).not_to be_nil
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2024, 9, 18, 2, 44, 17))
      # IMCCE: 2024-09-18T02:44:16Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(0.08521)
      # IMCCE: 0.08519
    end

    it "finds the 2023-05-05 penumbral lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2023, 4, 15),
        Time.utc(2023, 5, 15)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_penumbral
      expect(eclipse.partial).to be_nil
      expect(eclipse.total).to be_nil
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2023, 5, 5, 17, 23, 1))
      # IMCCE: 2023-05-05T17:22:55Z
      expect(eclipse.penumbral_magnitude.round(5)).to eq(0.9634)
      # IMCCE: 0.9635
    end

    it "signs gamma by the side of the shadow axis the Moon passes" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)
      earth_radius =
        Astronoby::Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS / 1000.0

      northward = calculator.events_between(
        Time.utc(2025, 3, 1),
        Time.utc(2025, 4, 1)
      ).first
      southward = calculator.events_between(
        Time.utc(2026, 3, 1),
        Time.utc(2026, 4, 1)
      ).first

      expect(northward.gamma.round(3)).to eq(0.348)
      expect(northward.gamma)
        .to be_within(1e-9).of(northward.shadow_axis_distance.km / earth_radius)
      expect(southward.gamma.round(3)).to eq(-0.376)
      expect(southward.gamma)
        .to be_within(1e-9).of(-southward.shadow_axis_distance.km / earth_radius)
    end

    it "exposes the shadow geometry at greatest eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2026, 3, 1),
        Time.utc(2026, 4, 1)
      )

      geometry = events.first.geometry
      expect(arcminutes(geometry.umbra_angular_radius)).to eq(41.91)
      # IMCCE: 41.9100'
      expect(arcminutes(geometry.penumbra_angular_radius)).to eq(74.17)
      # IMCCE: 74.1642'
      expect(arcminutes(geometry.angular_axis_distance)).to eq(21.58)
      # IMCCE: 21.5766'
      expect(degrees(geometry.position_angle)).to eq(208.22)
      # IMCCE: 208.19577°
    end

    it "exposes the shadow geometry at every contact" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2026, 3, 1),
        Time.utc(2026, 4, 1)
      )

      eclipse = events.first
      expect(arcminutes(eclipse.penumbral.starting_geometry.angular_axis_distance))
        .to eq(89.87)
      # IMCCE: 89.8698' (P1)
      expect(arcminutes(eclipse.partial.starting_geometry.angular_axis_distance))
        .to eq(57.58)
      # IMCCE: 57.5808' (U1)
      expect(arcminutes(eclipse.total.starting_geometry.angular_axis_distance))
        .to eq(26.3)
      # IMCCE: 26.3010' (U2)
      expect(arcminutes(eclipse.total.ending_geometry.angular_axis_distance))
        .to eq(26.28)
      # IMCCE: 26.2836' (U3)
      expect(arcminutes(eclipse.partial.ending_geometry.angular_axis_distance))
        .to eq(57.47)
      # IMCCE: 57.4728' (U4)
      expect(arcminutes(eclipse.penumbral.ending_geometry.angular_axis_distance))
        .to eq(89.69)
      # IMCCE: 89.6922' (P2)
    end

    it "reports the contact position angles IMCCE publishes" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2026, 3, 1),
        Time.utc(2026, 4, 1)
      )

      eclipse = events.first
      expect(degrees(eclipse.penumbral.starting_geometry.position_angle))
        .to eq(104.3)
      # IMCCE: 104.30027 degrees (P1)
      expect(degrees(eclipse.partial.starting_geometry.position_angle))
        .to eq(96.19)
      # IMCCE: 96.18881 degrees (U1)
      expect(degrees(eclipse.total.starting_geometry.position_angle))
        .to eq(243.07)
      # IMCCE: 243.07967 degrees (U2)
      expect(degrees(eclipse.total.ending_geometry.position_angle))
        .to eq(173.39)
      # IMCCE: 173.37756 degrees (U3)
      expect(degrees(eclipse.partial.ending_geometry.position_angle))
        .to eq(320.26)
      # IMCCE: 320.25722 degrees (U4)
      expect(degrees(eclipse.penumbral.ending_geometry.position_angle))
        .to eq(312.13)
      # IMCCE: 312.13033 degrees (P2)
    end

    it "closes the contact geometry on the definition of each contact" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2026, 3, 1),
        Time.utc(2026, 4, 1)
      )

      eclipse = events.first
      expect(eclipse.penumbral.starting_geometry.penumbral_magnitude)
        .to be_within(1e-5).of(0)
      expect(eclipse.penumbral.ending_geometry.penumbral_magnitude)
        .to be_within(1e-5).of(0)
      expect(eclipse.partial.starting_geometry.umbral_magnitude)
        .to be_within(1e-5).of(0)
      expect(eclipse.partial.ending_geometry.umbral_magnitude)
        .to be_within(1e-5).of(0)
      expect(eclipse.total.starting_geometry.umbral_magnitude)
        .to be_within(1e-5).of(1)
      expect(eclipse.total.ending_geometry.umbral_magnitude)
        .to be_within(1e-5).of(1)
    end

    it "finds and classifies every lunar eclipse between 2023 and 2025" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2023, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.map { |event| [event.instant.to_time.utc.strftime("%Y-%m-%d"), event.kind] })
        .to eq(
          [
            ["2023-05-05", :penumbral],
            ["2023-10-28", :partial],
            ["2024-03-25", :penumbral],
            ["2024-09-18", :partial],
            ["2025-03-14", :total],
            ["2025-09-07", :total]
          ]
        )
      # IMCCE: 2023-05-05 PenumbralEclipse
      # IMCCE: 2023-10-28 PartialEclipse
      # IMCCE: 2024-03-25 PenumbralEclipse
      # IMCCE: 2024-09-18 PartialEclipse
      # IMCCE: 2025-03-14 TotalEclipse
      # IMCCE: 2025-09-07 TotalEclipse
    end

    it "returns an empty array when no eclipse occurs in the range" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 2, 1)
      )

      expect(events).to be_empty
    end
  end

  def arcminutes(angle)
    (angle.degrees * 60).round(2)
  end

  def degrees(angle)
    angle.degrees.round(2)
  end
end
