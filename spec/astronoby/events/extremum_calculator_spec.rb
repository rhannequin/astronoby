# frozen_string_literal: true

RSpec.describe Astronoby::ExtremumCalculator do
  include TestEphemHelper

  describe "Moon apoapsis calculations" do
    it "finds all expected Moon apoapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      moon_apoapsises_2025 = [
        {time: Time.utc(2025, 1, 21, 4, 54, 8), distance_km: 404298.1},
        {time: Time.utc(2025, 2, 18, 1, 10, 13), distance_km: 404882.4},
        {time: Time.utc(2025, 3, 17, 16, 36, 44), distance_km: 405753.8},
        {time: Time.utc(2025, 4, 13, 22, 48, 10), distance_km: 406295.1},
        {time: Time.utc(2025, 5, 11, 0, 47, 4), distance_km: 406243.7},
        {time: Time.utc(2025, 6, 7, 10, 43, 49), distance_km: 405553.5},
        {time: Time.utc(2025, 7, 5, 2, 28, 47), distance_km: 404626.6},
        {time: Time.utc(2025, 8, 1, 20, 36, 27), distance_km: 404161.3},
        {time: Time.utc(2025, 8, 29, 15, 33, 37), distance_km: 404547.8},
        {time: Time.utc(2025, 9, 26, 9, 46, 5), distance_km: 405547.6},
        {time: Time.utc(2025, 10, 23, 23, 30, 25), distance_km: 406444.4},
        {time: Time.utc(2025, 11, 20, 2, 48, 23), distance_km: 406691.2},
        {time: Time.utc(2025, 12, 17, 6, 9, 6), distance_km: 406322.2}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      validate_events_match_reference(
        events, moon_apoapsises_2025,
        "full year 2025"
      )
      expect(events.length).to be_between(
        moon_apoapsises_2025.length - 1,
        moon_apoapsises_2025.length + 2
      )
    end

    it "finds expected Moon apoapsis events in Q1 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      q1_reference = [
        {time: Time.utc(2025, 1, 21, 4, 54, 8), distance_km: 404298.1},
        {time: Time.utc(2025, 2, 18, 1, 10, 13), distance_km: 404882.4},
        {time: Time.utc(2025, 3, 17, 16, 36, 44), distance_km: 405753.8}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 4, 1)
      )

      validate_events_match_reference(events, q1_reference, "Q1 2025")
    end

    it "maintains consistency between quarterly and yearly results" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )

      yearly_events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )
      q1_events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 4, 1)
      )
      q2_events = calculator.apoapsis_events_between(
        Time.utc(2025, 4, 1),
        Time.utc(2025, 7, 1)
      )
      q3_events = calculator.apoapsis_events_between(
        Time.utc(2025, 7, 1),
        Time.utc(2025, 10, 1)
      )
      q4_events = calculator.apoapsis_events_between(
        Time.utc(2025, 10, 1),
        Time.utc(2026, 1, 1)
      )

      quarterly_events = q1_events + q2_events + q3_events + q4_events
      quarterly_events.each do |quarterly_event|
        quarterly_time = quarterly_event.instant.to_time
        matching_yearly = yearly_events.find do |yearly_event|
          yearly_time = yearly_event.instant.to_time
          (quarterly_time - yearly_time).abs < 60
        end
        expect(matching_yearly).not_to be_nil,
          "Quarterly event at #{quarterly_time} not found in yearly results"
      end
    end

    it "finds expected Moon apoapsis events in Q2 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      q2_reference = [
        {time: Time.utc(2025, 4, 13, 22, 48, 10), distance_km: 406295.1},
        {time: Time.utc(2025, 5, 11, 0, 47, 4), distance_km: 406243.7},
        {time: Time.utc(2025, 6, 7, 10, 43, 49), distance_km: 405553.5}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 4, 1),
        Time.utc(2025, 7, 1)
      )

      validate_events_match_reference(events, q2_reference, "Q2 2025")
    end

    it "finds expected Moon apoapsis events in Q3 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      q3_reference = [
        {time: Time.utc(2025, 7, 5, 2, 28, 47), distance_km: 404626.6},
        {time: Time.utc(2025, 8, 1, 20, 36, 27), distance_km: 404161.3},
        {time: Time.utc(2025, 8, 29, 15, 33, 37), distance_km: 404547.8},
        {time: Time.utc(2025, 9, 26, 9, 46, 5), distance_km: 405547.6}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 7, 1),
        Time.utc(2025, 10, 1)
      )

      validate_events_match_reference(events, q3_reference, "Q3 2025")
    end

    it "finds expected Moon apoapsis events in Q4 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      q4_reference = [
        {time: Time.utc(2025, 10, 23, 23, 30, 25), distance_km: 406444.4},
        {time: Time.utc(2025, 11, 20, 2, 48, 23), distance_km: 406691.2},
        {time: Time.utc(2025, 12, 17, 6, 9, 6), distance_km: 406322.2}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 10, 1),
        Time.utc(2026, 1, 1)
      )

      validate_events_match_reference(events, q4_reference, "Q4 2025")
    end
  end

  describe "Moon periapsis calculations" do
    it "finds all expected Moon periapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      moon_periapsises_2025 = [
        {time: Time.utc(2025, 1, 8, 0, 1, 5), distance_km: 370170.7},
        {time: Time.utc(2025, 2, 2, 2, 46, 52), distance_km: 367456.8},
        {time: Time.utc(2025, 3, 1, 21, 21, 30), distance_km: 361963.6},
        {time: Time.utc(2025, 3, 30, 5, 25, 12), distance_km: 358127.7},
        {time: Time.utc(2025, 4, 27, 16, 17, 51), distance_km: 357118.5},
        {time: Time.utc(2025, 5, 26, 1, 33, 47), distance_km: 359022.3},
        {time: Time.utc(2025, 6, 23, 4, 44, 15), distance_km: 363178.2},
        {time: Time.utc(2025, 7, 20, 13, 54, 49), distance_km: 368041.4},
        {time: Time.utc(2025, 8, 14, 17, 59, 1), distance_km: 369288.3},
        {time: Time.utc(2025, 9, 10, 12, 9, 42), distance_km: 364777.4},
        {time: Time.utc(2025, 10, 8, 12, 38, 28), distance_km: 359819.0},
        {time: Time.utc(2025, 11, 5, 22, 27, 18), distance_km: 356832.7},
        {time: Time.utc(2025, 12, 4, 11, 7, 28), distance_km: 356962.6}
      ]

      events = calculator.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      validate_events_match_reference(
        events, moon_periapsises_2025,
        "full year 2025"
      )
      expect(events.length).to be_between(
        moon_periapsises_2025.length - 1,
        moon_periapsises_2025.length + 1
      )
    end

    it "finds periapsis events with smaller distances than apoapsis events" do
      ephem = test_ephem_inpop
      periapsis_calc = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      apoapsis_calc = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )

      periapsis_events = periapsis_calc.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 2, 1)
      )
      apoapsis_events = apoapsis_calc.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 2, 1)
      )

      if periapsis_events.any? && apoapsis_events.any?
        periapsis_distance = periapsis_events.first.value
        apoapsis_distance = apoapsis_events.first.value
        expect(periapsis_distance).to be < apoapsis_distance,
          "Periapsis distance should be less than apoapsis distance"
      end
    end
  end

  describe "Mercury calculations" do
    it "finds all expected Mercury apoapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Mercury,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      mercury_apoapsises_2025 = [
        {time: Time.utc(2025, 1, 19, 14, 0, 39), distance_km: 69817562},
        {time: Time.utc(2025, 4, 17, 13, 17, 17), distance_km: 69817856},
        {time: Time.utc(2025, 7, 14, 12, 32, 25), distance_km: 69817920},
        {time: Time.utc(2025, 10, 10, 11, 47, 36), distance_km: 69817798}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      mercury_apoapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil,
          "Expected Mercury aphelion at #{expected[:time]} not found"
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(50000).of(
            expected[:distance_km]
          )
        end
      end
    end

    it "finds all expected Mercury periapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Mercury,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      mercury_periapsises_2025 = [
        {time: Time.utc(2025, 3, 4, 13, 38, 58), distance_km: 46000816},
        {time: Time.utc(2025, 5, 31, 12, 54, 56), distance_km: 45999952},
        {time: Time.utc(2025, 8, 27, 12, 10, 10), distance_km: 45999996},
        {time: Time.utc(2025, 11, 23, 11, 25, 18), distance_km: 46000211}
      ]

      events = calculator.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      mercury_periapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil,
          "Expected Mercury perihelion at #{expected[:time]} not found"
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(50000).of(
            expected[:distance_km]
          )
        end
      end
    end
  end

  describe "Venus calculations" do
    it "finds expected Venus apoapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Venus,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      venus_apoapsises_2025 = [
        {time: Time.utc(2025, 6, 12, 2, 20, 37), distance_km: 108942037}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      venus_apoapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(10000).of(
            expected[:distance_km]
          )
        end
      end
    end

    it "finds expected Venus periapsis events in full year 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Venus,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      venus_periapsises_2025 = [
        {time: Time.utc(2025, 2, 19, 19, 52, 57), distance_km: 107479148},
        {time: Time.utc(2025, 10, 2, 8, 55, 27), distance_km: 107474547}
      ]

      events = calculator.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      venus_periapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(10000).of(
            expected[:distance_km]
          )
        end
      end
    end
  end

  describe "Earth calculations" do
    it "finds expected Earth apoapsis event in July 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Earth,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      earth_apoapsises_2025 = [
        {time: Time.utc(2025, 7, 3, 19, 54, 43), distance_km: 152087738}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      earth_apoapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(10000).of(
            expected[:distance_km]
          )
        end
      end
    end

    it "finds expected Earth periapsis event in January 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Earth,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      earth_periapsises_2025 = [
        {time: Time.utc(2025, 1, 4, 13, 28, 5), distance_km: 147103686}
      ]

      events = calculator.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      earth_periapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 3600
        end
        expect(matching_event).not_to be_nil
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(10000).of(
            expected[:distance_km]
          )
        end
      end
    end
  end

  describe "Mars calculations" do
    it "finds expected Mars apoapsis event in April 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Mars,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )
      mars_apoapsises_2025 = [
        {time: Time.utc(2025, 4, 16, 22, 12, 19), distance_km: 249239465}
      ]

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      mars_apoapsises_2025.each do |expected|
        matching_event = events.find do |event|
          (event.instant.to_time - expected[:time]).abs < 7200
        end
        expect(matching_event).not_to be_nil
        if matching_event
          actual_distance_km = matching_event.value.km
          expect(actual_distance_km).to be_within(100000).of(
            expected[:distance_km]
          )
        end
      end
    end

    it "handles Mars long orbital period correctly" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Mars,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.length).to be_between(0, 2)
    end

    it "correctly finds no Mars periapsis events in 2025" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Mars,
        primary_body: Astronoby::Sun,
        ephem: ephem,
        samples_per_period: 60
      )

      events = calculator.periapsis_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.length).to be_between(0, 1)
    end
  end

  describe "multi-body consistency" do
    it "produces consistent results across all celestial bodies" do
      ephem = test_ephem_inpop
      start_time = Time.utc(2025, 1, 1)
      end_time = Time.utc(2026, 1, 1)

      calculators = {
        moon: described_class.new(
          body: Astronoby::Moon,
          primary_body: Astronoby::Earth,
          ephem: ephem,
          samples_per_period: 60
        ),
        mercury: described_class.new(
          body: Astronoby::Mercury,
          primary_body: Astronoby::Sun,
          ephem: ephem,
          samples_per_period: 60
        ),
        venus: described_class.new(
          body: Astronoby::Venus,
          primary_body: Astronoby::Sun,
          ephem: ephem,
          samples_per_period: 60
        ),
        earth: described_class.new(
          body: Astronoby::Earth,
          primary_body: Astronoby::Sun,
          ephem: ephem,
          samples_per_period: 60
        ),
        mars: described_class.new(
          body: Astronoby::Mars,
          primary_body: Astronoby::Sun,
          ephem: ephem,
          samples_per_period: 60
        )
      }

      calculators.each do |_body_name, calculator|
        events = calculator.apoapsis_events_between(start_time, end_time)

        expect(events).to be_an(Array)

        events.each do |event|
          event_time = event.instant.to_time
          expect(event_time).to be >= start_time
          expect(event_time).to be < end_time
          expect(event.value).to be_positive
        end

        times = events.map { |e| e.instant.to_time }
        expect(times).to eq(times.sort)
      end
    end
  end

  describe "edge cases and boundary conditions" do
    it "handles very short ranges without spurious events" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )

      events = calculator.apoapsis_events_between(
        Time.utc(2025, 6, 15, 12, 0, 0),
        Time.utc(2025, 6, 15, 13, 0, 0)
      )

      expect(events.length).to eq(0)
    end

    it "handles ranges starting exactly at event times" do
      ephem = test_ephem_inpop
      calculator = described_class.new(
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        ephem: ephem,
        samples_per_period: 60
      )
      first_event_time = Time.utc(2025, 1, 21, 4, 54, 8)
      end_time = first_event_time + (60 * 86400)

      events = calculator.apoapsis_events_between(first_event_time, end_time)

      expect(events).to be_an(Array)
      expect(events.length).to be >= 1

      times = events.map { |e| e.instant.to_time }
      expect(times.uniq.length).to eq(times.length)
    end

    it "does not create events exactly at range boundaries" do
      ephem = test_ephem_inpop
      extremum_calculator = described_class.new(
        ephem: ephem,
        body: Astronoby::Moon,
        primary_body: Astronoby::Earth,
        samples_per_period: 60
      )
      start_time = Time.utc(2025, 6, 1)
      end_time = Time.utc(2025, 6, 8)
      start_jd = Astronoby::Instant.from_time(start_time).tt
      end_jd = Astronoby::Instant.from_time(end_time).tt

      extrema = extremum_calculator.find_extrema(
        start_jd,
        end_jd,
        type: :maximum
      )

      extrema.each do |extreme|
        event_time = extreme.instant.to_time
        expect(event_time).not_to eq(start_time)
        expect(event_time).not_to eq(end_time)
        expect((event_time - start_time).abs).to be > 60
        expect((event_time - end_time).abs).to be > 60
      end
    end
  end

  describe "algorithm validation across different orbital periods" do
    it "handles different orbital periods correctly" do
      ephem = test_ephem_inpop
      start_jd = Astronoby::Instant.from_time(Time.utc(2025, 1, 1)).tt
      end_jd = Astronoby::Instant.from_time(Time.utc(2025, 4, 1)).tt

      bodies = [
        {
          name: "Moon",
          body: Astronoby::Moon,
          primary: Astronoby::Earth,
          period: 27.504339
        },
        {
          name: "Mercury",
          body: Astronoby::Mercury,
          primary: Astronoby::Sun,
          period: 87.969
        },
        {
          name: "Venus",
          body: Astronoby::Venus,
          primary: Astronoby::Sun,
          period: 224.701
        },
        {
          name: "Earth",
          body: Astronoby::Earth,
          primary: Astronoby::Sun,
          period: 365.256
        },
        {
          name: "Mars",
          body: Astronoby::Mars,
          primary: Astronoby::Sun,
          period: 686.98
        }
      ]

      bodies.each do |body_info|
        finder = described_class.new(
          ephem: ephem,
          body: body_info[:body],
          primary_body: body_info[:primary],
          samples_per_period: 60
        )

        extrema = finder.find_extrema(start_jd, end_jd, type: :maximum)

        expect(extrema).to be_an(Array)

        extrema.each do |extreme|
          event_time = extreme.instant.to_time
          expect(event_time).to be >= Time.utc(2025, 1, 1)
          expect(event_time).to be < Time.utc(2025, 4, 1)
        end
      end
    end
  end

  def validate_events_match_reference(events, reference_data, period_name)
    reference_data.each do |expected|
      matching_event = events.find do |event|
        (event.instant.to_time - expected[:time]).abs < 60
      end

      expect(matching_event).not_to be_nil,
        "Expected event at #{expected[:time]} not found in #{period_name}"

      if matching_event
        actual_distance_km = matching_event.value.km
        expect(actual_distance_km).to be_within(1.0).of(expected[:distance_km]),
          "Distance mismatch in #{period_name} for event at #{expected[:time]}"
      end
    end
  end
end
