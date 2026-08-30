# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipseVisibility do
  include TestEphemHelper

  describe "#circumstance" do
    it "is entirely visible where the Moon is up from start to end" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      mexico_city = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(19.43),
        longitude: Astronoby::Angle.from_degrees(-99.13)
      )

      visibility = eclipse.visibility_from(mexico_city)

      expect(visibility.circumstance).to eq(described_class::ENTIRELY_VISIBLE)
      expect(visibility).to be_visible
      expect(visibility).to be_entirely_visible
    end

    it "ends after moonset over Paris" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)

      expect(visibility.circumstance).to eq(described_class::ENDS_AFTER_MOONSET)
      expect(visibility).to be_visible
      expect(visibility).not_to be_entirely_visible
    end

    it "begins before moonrise over Tokyo" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      tokyo = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(35.68),
        longitude: Astronoby::Angle.from_degrees(139.69)
      )

      visibility = eclipse.visibility_from(tokyo)

      expect(visibility.circumstance)
        .to eq(described_class::BEGINS_BEFORE_MOONRISE)
      expect(visibility).to be_visible
    end

    it "is not visible from the daylit hemisphere" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      delhi = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(28.61),
        longitude: Astronoby::Angle.from_degrees(77.21)
      )

      visibility = eclipse.visibility_from(delhi)

      expect(visibility.circumstance).to eq(described_class::NOT_VISIBLE)
      expect(visibility).not_to be_visible
      expect(visibility.observable_windows).to be_empty
    end
  end

  describe "#coverage" do
    it "reports each phase of the eclipse separately" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      reykjavik = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(64.15),
        longitude: Astronoby::Angle.from_degrees(-21.94)
      )

      visibility = eclipse.visibility_from(reykjavik)

      expect(visibility.coverage(:total))
        .to eq(described_class::ENTIRELY_VISIBLE)
      expect(visibility.coverage(:partial))
        .to eq(described_class::PARTIALLY_VISIBLE)
      expect(visibility.coverage(:penumbral))
        .to eq(described_class::PARTIALLY_VISIBLE)
    end

    it "reports a phase entirely below the horizon" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      tokyo = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(35.68),
        longitude: Astronoby::Angle.from_degrees(139.69)
      )

      visibility = eclipse.visibility_from(tokyo)

      expect(visibility.coverage(:total)).to eq(described_class::NOT_VISIBLE)
      expect(visibility.coverage(:partial)).to eq(described_class::NOT_VISIBLE)
      expect(visibility.coverage(:penumbral))
        .to eq(described_class::PARTIALLY_VISIBLE)
    end

    it "returns nil for a phase the eclipse does not have" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2027, 2, 1),
        end_time: Time.utc(2027, 3, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)

      expect(visibility.coverage(:penumbral))
        .to eq(described_class::ENTIRELY_VISIBLE)
      expect(visibility.coverage(:partial)).to be_nil
      expect(visibility.coverage(:total)).to be_nil
    end

    it "rejects anything that is not a phase of a lunar eclipse" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)

      expect { visibility.coverage(:annular) }
        .to raise_error(Astronoby::UnsupportedEventError, /annular/)
    end
  end

  describe "#horizon_crossings" do
    it "puts the Moon on the horizon, checked against the ephemeris" do
      ephem = test_ephem_inpop_2000_2050
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: ephem,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      observers = [
        [48.86, 2.35],      # Paris
        [35.68, 139.69],    # Tokyo
        [64.15, -21.94],    # Reykjavik
        [-33.92, 18.42],    # Cape Town
        [-41.29, 174.78]    # Wellington
      ].map do |latitude, longitude|
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(latitude),
          longitude: Astronoby::Angle.from_degrees(longitude)
        )
      end
      crossings_checked = 0

      observers.each do |observer|
        eclipse.visibility_from(observer).horizon_crossings.each do |crossing|
          topocentric = Astronoby::Moon
            .new(ephem: ephem, instant: crossing)
            .observed_by(observer)
          horizon = Astronoby::Horizon.angle_for(
            body: Astronoby::Moon,
            distance: topocentric.distance
          )
          difference =
            (topocentric.horizontal.altitude.degrees - horizon.degrees) * 3600

          expect(difference.abs).to be < 10
          crossings_checked += 1
        end
      end

      expect(crossings_checked).to eq(5)
    end

    it "reports the moonset that ends the eclipse over Paris" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      crossings = eclipse.visibility_from(paris).horizon_crossings

      expect(crossings.size).to eq(1)
      expect(crossings.first.to_time.round)
        .to be_within(30).of(Time.utc(2025, 3, 14, 6, 11, 42))
    end

    it "is empty when the Moon does not cross the horizon" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      mexico_city = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(19.43),
        longitude: Astronoby::Angle.from_degrees(-99.13)
      )
      delhi = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(28.61),
        longitude: Astronoby::Angle.from_degrees(77.21)
      )

      expect(eclipse.visibility_from(mexico_city).horizon_crossings).to be_empty
      expect(eclipse.visibility_from(delhi).horizon_crossings).to be_empty
    end
  end

  describe "#observable_windows" do
    it "spans the whole eclipse when it is entirely visible" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      mexico_city = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(19.43),
        longitude: Astronoby::Angle.from_degrees(-99.13)
      )

      windows = eclipse.visibility_from(mexico_city).observable_windows

      expect(windows.size).to eq(1)
      expect(windows.first.first).to eq(eclipse.penumbral.starting_instant)
      expect(windows.first.last).to eq(eclipse.penumbral.ending_instant)
    end

    it "runs from the first penumbral contact to moonset" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)
      windows = visibility.observable_windows

      expect(windows.size).to eq(1)
      expect(windows.first.first).to eq(eclipse.penumbral.starting_instant)
      expect(windows.first.last).to eq(visibility.horizon_crossings.first)
    end

    it "runs from moonrise to the last penumbral contact" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      tokyo = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(35.68),
        longitude: Astronoby::Angle.from_degrees(139.69)
      )

      visibility = eclipse.visibility_from(tokyo)
      windows = visibility.observable_windows

      expect(windows.size).to eq(1)
      expect(windows.first.first).to eq(visibility.horizon_crossings.first)
      expect(windows.first.last).to eq(eclipse.penumbral.ending_instant)
    end
  end

  describe "#above_horizon_at?" do
    it "agrees with the ephemeris at every point of the eclipse" do
      ephem = test_ephem_inpop_2000_2050
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: ephem,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      observers = [
        [48.86, 2.35],      # Paris
        [35.68, 139.69],    # Tokyo
        [-41.29, 174.78],   # Wellington
        [-33.92, 18.42]     # Cape Town
      ].map do |latitude, longitude|
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(latitude),
          longitude: Astronoby::Angle.from_degrees(longitude)
        )
      end
      first_contact = eclipse.penumbral.starting_instant.tt
      last_contact = eclipse.penumbral.ending_instant.tt

      observers.each do |observer|
        visibility = eclipse.visibility_from(observer)

        8.times do |step|
          instant = Astronoby::Instant.from_terrestrial_time(
            first_contact + (last_contact - first_contact) * step / 7.0
          )
          topocentric = Astronoby::Moon
            .new(ephem: ephem, instant: instant)
            .observed_by(observer)
          horizon = Astronoby::Horizon.angle_for(
            body: Astronoby::Moon,
            distance: topocentric.distance
          )

          expect(visibility.above_horizon_at?(instant))
            .to be(topocentric.horizontal.altitude > horizon)
        end
      end
    end

    it "rejects an instant outside the eclipse" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)

      expect {
        visibility.above_horizon_at?(
          Astronoby::Instant.from_time(Time.utc(2025, 3, 15))
        )
      }.to raise_error(ArgumentError, /penumbral contact/)
    end

    it "is true while the Moon is up and false once it has set" do
      eclipse = Astronoby::Moon.eclipse_events(
        ephem: test_ephem_inpop_2000_2050,
        start_time: Time.utc(2025, 3, 1),
        end_time: Time.utc(2025, 4, 1)
      ).first
      paris = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.86),
        longitude: Astronoby::Angle.from_degrees(2.35)
      )

      visibility = eclipse.visibility_from(paris)

      expect(visibility.above_horizon_at?(eclipse.penumbral.starting_instant))
        .to be true
      expect(visibility.above_horizon_at?(eclipse.penumbral.ending_instant))
        .to be false
    end
  end

  it "agrees with the moonrise and moonset the ephemeris gives" do
    ephem = test_ephem_inpop_2000_2050
    eclipse = Astronoby::Moon.eclipse_events(
      ephem: ephem,
      start_time: Time.utc(2025, 3, 1),
      end_time: Time.utc(2025, 4, 1)
    ).first
    observers = [
      [48.86, 2.35],      # Paris
      [35.68, 139.69],    # Tokyo
      [-33.92, 18.42],    # Cape Town
      [64.15, -21.94],    # Reykjavik
      [-41.29, 174.78]    # Wellington
    ].map do |latitude, longitude|
      Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(latitude),
        longitude: Astronoby::Angle.from_degrees(longitude)
      )
    end
    compared = 0

    observers.each do |observer|
      crossings = eclipse.visibility_from(observer).horizon_crossings
      calculator = Astronoby::RiseTransitSetCalculator.new(
        body: Astronoby::Moon,
        observer: observer,
        ephem: ephem
      )

      crossings.each do |crossing|
        time = crossing.to_time
        candidates = [-1, 0, 1].flat_map do |offset|
          events = calculator.events_on(time.to_date + offset)
          events.rising_times + events.setting_times
        end.compact
        closest = candidates.min_by { |candidate| (candidate - time).abs }

        expect(closest).to be_within(2).of(time)
        compared += 1
      end
    end

    expect(compared).to eq(5)
  end

  it "needs no ephemeris, so it survives a round trip through a cache" do
    eclipse = Astronoby::Moon.eclipse_events(
      ephem: test_ephem_inpop_2000_2050,
      start_time: Time.utc(2025, 3, 1),
      end_time: Time.utc(2025, 4, 1)
    ).first
    paris = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.86),
      longitude: Astronoby::Angle.from_degrees(2.35)
    )
    cached = Marshal.load(Marshal.dump(eclipse))

    visibility = cached.visibility_from(paris)

    expect(visibility.circumstance).to eq(described_class::ENDS_AFTER_MOONSET)
    expect(visibility.coverage(:total)).to eq(described_class::NOT_VISIBLE)
    expect(visibility.horizon_crossings.map { |instant| instant.to_time.round })
      .to eq(
        eclipse
          .visibility_from(paris)
          .horizon_crossings
          .map { |instant| instant.to_time.round }
      )
  end

  it "is immutable" do
    eclipse = Astronoby::Moon.eclipse_events(
      ephem: test_ephem_inpop_2000_2050,
      start_time: Time.utc(2025, 3, 1),
      end_time: Time.utc(2025, 4, 1)
    ).first
    paris = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.86),
      longitude: Astronoby::Angle.from_degrees(2.35)
    )

    expect(eclipse.visibility_from(paris)).to be_frozen
  end

  context "when the Moon's right ascension crosses 0h during the eclipse" do
    it "is unaffected by where the wrap falls" do
      geometry_at = lambda do |right_ascension|
        Astronoby::LunarEclipseGeometry.new(
          axis_distance: Astronoby::Distance.from_kilometers(2401.3),
          position_angle: Astronoby::Angle.from_degrees(208.2),
          umbra_radius: Astronoby::Distance.from_kilometers(4664.4),
          penumbra_radius: Astronoby::Distance.from_kilometers(8254.0),
          moon_distance: Astronoby::Distance.from_kilometers(384_400.0),
          moon_coordinates: Astronoby::Coordinates::Equatorial.new(
            right_ascension: Astronoby::Angle.from_degrees(
              right_ascension % 360.0
            ),
            declination: Astronoby::Angle.from_degrees(2.7)
          ),
          north_of_axis: true
        )
      end
      eclipse_at = lambda do |right_ascension|
        greatest = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 7))

        Astronoby::LunarEclipse.new(
          instant: greatest,
          kind: Astronoby::LunarEclipse::PENUMBRAL,
          geometry: geometry_at.call(right_ascension),
          penumbral: Astronoby::LunarEclipsePhase.new(
            starting_instant:
              Astronoby::Instant.from_terrestrial_time(greatest.tt - 0.1),
            ending_instant:
              Astronoby::Instant.from_terrestrial_time(greatest.tt + 0.1),
            starting_geometry: geometry_at.call(right_ascension - 1.3),
            ending_geometry: geometry_at.call(right_ascension + 1.3)
          )
        )
      end

      wrapping = eclipse_at.call(0.0)
      turned = eclipse_at.call(180.0)
      wrapping_visibility = wrapping.visibility_from(
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.86),
          longitude: Astronoby::Angle.from_degrees(2.35)
        )
      )
      turned_visibility = turned.visibility_from(
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.86),
          longitude: Astronoby::Angle.from_degrees(2.35 - 180.0)
        )
      )
      first_contact = wrapping.penumbral.starting_instant.tt
      last_contact = wrapping.penumbral.ending_instant.tt

      9.times do |step|
        instant = Astronoby::Instant.from_terrestrial_time(
          first_contact + (last_contact - first_contact) * step / 8.0
        )

        expect(wrapping_visibility.above_horizon_at?(instant))
          .to be(turned_visibility.above_horizon_at?(instant))
      end

      expect(wrapping_visibility.circumstance)
        .to eq(turned_visibility.circumstance)

      crossings = wrapping_visibility.horizon_crossings
      turned_crossings = turned_visibility.horizon_crossings
      expect(crossings.size).to eq(1)
      expect(turned_crossings.size).to eq(1)
      expect(crossings.first.tt)
        .to be_within(1e-9).of(turned_crossings.first.tt)
    end
  end
end
