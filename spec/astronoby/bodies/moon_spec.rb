# frozen_string_literal: true

RSpec.describe Astronoby::Moon do
  include TestEphemHelper

  describe "#geometric" do
    it "returns a Geometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

      expect(geometric).to be_a(Astronoby::Geometric)
      expect(geometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(4),
            Astronoby::Distance.from_kilometers(6)
          ]
        )
      expect(geometric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_kilometers_per_day(8),
            Astronoby::Velocity.from_kilometers_per_day(10),
            Astronoby::Velocity.from_kilometers_per_day(12)
          ]
        )
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-139986171, 45092089, 19573501])
      # IMCCE:    -139986152 45092088 19573500
      # Skyfield: -139986173 45092085 19573500

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("10h 48m 34.8736s")
      # IMCCE:    10h 48m 34.8733s
      # Skyfield: 10h 48m 34.87s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+7° 34′ 51.4383″")
      # IMCCE:    +7° 34′ 51.439″
      # Skyfield: +7° 34′ 51.4″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+0° 0′ 30.2285″")
      # IMCCE:    +0° 0′ 30.227″
      # Skyfield: +0° 0′ 33.1″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+160° 39′ 3.37″")
      # IMCCE:    +160° 39′ 3.365″
      # Skyfield: +161° 0′ 10.3″

      expect(geometric.distance.au)
        .to eq(0.99176717802305)
      # IMCCE:    0.991767054173
      # Skyfield: 0.9917671790668138
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-10408.41307, -24901.72774, -10687.38588])
      # IMCCE:    -10408.41236 -24901.72816 -10687.38603
      # Skyfield: -10408.41257 -24901.72803 -10687.38600
    end

    context "with an INPOP ephemeris" do
      it "returns a Geometric position" do
        time = Time.utc(2025, 2, 7, 12)
        instant = Astronoby::Instant.from_time(time)
        ephem = test_ephem_inpop
        planet = described_class.new(instant: instant, ephem: ephem)

        geometric = planet.geometric

        expect(geometric).to be_a(Astronoby::Geometric)
      end
    end
  end

  describe "#astrometric" do
    it "returns an Astrometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("23h 36m 54.8281s")
      # IMCCE:    23h 36m 54.8384s
      # Skyfield: 23h 36m 54.83s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-2° 50′ 44.532″")
      # IMCCE:    -2° 50′ 44.459″
      # Skyfield: -2° 50′ 44.5″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("-0° 19′ 14.6203″")
      # IMCCE:    -0° 19′ 14.614″
      # Skyfield: -0° 19′ 14.9″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+353° 34′ 30.4661″")
      # IMCCE:    +353° 34′ 30.636″
      # Skyfield: +353° 55′ 37.5″

      expect(astrometric.distance.au)
        .to eq(0.0024238110763858613)
      # IMCCE:    0.002423811046
      # Skyfield: 0.002423811056514585
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([105.49678, 948.38896, 519.75459])
      # IMCCE:    105.49594 948.38904 519.75463
      # Skyfield: 105.49622 948.38902 519.75462
    end
  end

  describe "#mean_of_date" do
    it "returns a MeanOfDate position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date).to be_a(Astronoby::MeanOfDate)
      expect(mean_of_date.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(mean_of_date.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(mean_of_date.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("23h 38m 11.1758s")
      # IMCCE:  23h 38m 11.1872s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-2° 42′ 30.2921″")
      # IMCCE:  -2° 42′ 30.235″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-0° 19′ 14.8364″")
      # IMCCE:  -0° 19′ 14.850″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+353° 55′ 16.6299″")
      # IMCCE:  +353° 55′ 16.808″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(0.0024237519764390646)
      # IMCCE: 0.002423751946
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([98.89104, 948.96211, 520.0036])
      # IMCCE:  98.89017  948.96221  520.0036
    end
  end

  describe "#apparent" do
    it "returns an Apparent position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent).to be_a(Astronoby::Apparent)
      expect(apparent.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(apparent.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(apparent.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("23h 38m 11.2559s")
      # IMCCE:    23h 38m 11.2637s
      # Skyfield: 23h 38m 11.26s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-2° 42′ 31.0309″")
      # IMCCE:    -2° 42′ 30.932″
      # Skyfield: -2° 42′ 31.0″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-0° 19′ 15.9896″")
      # IMCCE:    -0° 19′ 15.945″
      # Skyfield: -0° 19′ 14.9″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+353° 55′ 17.4387″")
      # IMCCE:    +353° 55′ 17.585″
      # Skyfield: +353° 55′ 17.5″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(0.0024238110763858613)
      # IMCCE:    0.002423811046
      # Skyfield: 0.002423811056514584
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([99, 949, 520])
      # IMCCE:  99, 949, 520
    end

    context "with cache enabled" do
      it "returns the right apparent position with acceptable precision" do
        Astronoby.configuration.cache_enabled = false
        ephem = test_ephem_moon
        first_time = Time.utc(2025, 5, 26, 10, 46, 55)
        first_instant = Astronoby::Instant.from_time(first_time)
        second_time = Time.utc(2025, 5, 26, 10, 46, 56)
        second_instant = Astronoby::Instant.from_time(second_time)
        precision = Astronoby::Angle.from_degree_arcseconds(0.0001)

        _first_apparent = described_class
          .new(instant: first_instant, ephem: ephem)
          .apparent
        second_apparent = described_class
          .new(instant: second_instant, ephem: ephem)
          .apparent
        Astronoby.configuration.cache_enabled = true
        _first_apparent_with_cache = described_class
          .new(instant: first_instant, ephem: ephem)
          .apparent
        second_apparent_with_cache = described_class
          .new(instant: second_instant, ephem: ephem)
          .apparent

        aggregate_failures do
          expect(second_apparent.equatorial.right_ascension.degrees).to(
            be_within(precision.degrees).of(
              second_apparent_with_cache.equatorial.right_ascension.degrees
            )
          )
        end

        Astronoby.reset_configuration!
      end
    end
  end

  describe "#observed_by" do
    it "returns a Topocentric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      expect(topocentric).to be_a(Astronoby::Topocentric)
      expect(topocentric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(topocentric.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(topocentric.horizontal).to be_a(Astronoby::Coordinates::Horizontal)
      expect(topocentric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(1.364917),
        longitude: Astronoby::Angle.from_degrees(103.822872)
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      aggregate_failures do
        expect(topocentric.equatorial.right_ascension.str(:hms))
          .to eq("23h 42m 13.1516s")
        # IMCCE:      23h 42m 13.1008s
        # Horizons:   23h 42m 13.093946s
        # Stellarium: 23h 42m 13.16s
        # Skyfield:   23h 42m 13.10s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("-2° 43′ 49.2264″")
        # IMCCE:      -2° 43′ 50.110″
        # Horizons:   -2° 43′ 50.12197″
        # Stellarium: -2° 43′ 49.9″
        # Skyfield:   -2° 43′ 50.1″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+92° 40′ 7.7766″")
        # IMCCE:      +92° 40′ 8.760″
        # Horizons:   +92° 40′ 8.7334″
        # Stellarium: +92° 40′ 8.7″
        # Skyfield:   +92° 40′ 8.5″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("-2° 44′ 25.6155″")
        # IMCCE:      -2° 44′ 23.640″
        # Horizons:   -2° 44′ 22.8363″
        # Stellarium: -2° 44′ 24.6″
        # Skyfield:   -2° 44′ 22.9″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 32′ 55.4816″")
        # IMCCE:      +0° 32′ 55.3033″
        # Horizons:   +0° 32′ 55.303″
        # Stellarium: +0° 32′ 55.33″
        # Skyfield:   +0° 32′ 55″
      end
    end

    context "with refraction" do
      it "computes the correct position" do
        time = Time.utc(2025, 3, 1, 12)
        instant = Astronoby::Instant.from_time(time)
        ephem = test_ephem_moon
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(1.364917),
          longitude: Astronoby::Angle.from_degrees(103.822872)
        )
        planet = described_class.new(instant: instant, ephem: ephem)

        topocentric = planet.observed_by(observer)
        horizontal = topocentric.horizontal(refraction: true)

        aggregate_failures do
          expect(horizontal.azimuth.str(:dms))
            .to eq("+270° 40′ 43.3759″")
          # Horizons:   +270° 40′ 41.7498″
          # Stellarium: +270° 40′ 42.5″
          # Skyfield:   +270° 40′ 41.7″

          expect(horizontal.altitude.str(:dms))
            .to eq("+6° 50′ 17.8399″")
          # Horizons:   +6° 50′ 19.33″
          # Stellarium: +6° 50′ 0.2″
          # Skyfield:   +6° 50′ 15.7″
        end
      end
    end
  end

  describe "::monthly_phase_events" do
    it "returns an array" do
      moon_phases = described_class.monthly_phase_events(year: 2024, month: 1)

      expect(moon_phases).to be_an(Array)
    end
  end

  describe "#phase_angle" do
    it "returns the phase angle for 2025-04-12" do
      time = Time.utc(2025, 4, 12)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      phase_angle = moon.phase_angle

      expect(phase_angle.degrees.round(4)).to eq 11.0746
      # Result from IMCCE: 11.0802°
    end
  end

  describe "#illuminated_fraction" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.180
    it "returns the illuminated fraction for 2015-01-01" do
      time = Time.utc(2015, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.8243
      # Result from the book: 0.82
      # Result from IMCCE: 0.824
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2005-08-09" do
      time = Time.utc(2005, 8, 9)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.1315
      # Result from the book: 0.13
      # Result from IMCCE: 0.132
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2005-05-06" do
      time = Time.utc(2005, 5, 6, 14, 30)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.0347
      # Result from the book: 0.06
      # Result from IMCCE: 0.035
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 67 - The phases of the Moon, p.171
    it "returns the apparent ecliptic coordinates for 2003-09-01" do
      # Example gives 2003-09-01 00:00:00 TT (and not UTC)
      time = Time.utc(2003, 9, 1, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.2257
      # Result from the book: 0.225
      # Result from IMCCE: 0.226
    end
  end

  describe "#current_phase_fraction" do
    it "returns the mean elongation's fraction for 2024-01-01" do
      time = Time.utc(2024, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_moon
      moon = described_class.new(instant: instant, ephem: ephem)

      phase_fraction = moon.current_phase_fraction

      expect(phase_fraction.round(2)).to eq 0.66
    end
  end
end
