# frozen_string_literal: true

RSpec.describe Astronoby::Seasons do
  include TestEphemHelper

  describe "#in" do
    it "returns the equinoxes and solstices of the year" do
      sky = Astronoby::Sky.new(test_ephem)

      year = sky.seasons.in(2025)

      expect(year.march_equinox.instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 3, 20, 9, 1, 28.93))
      # IMCCE:    2025-03-20T09:01:29Z
      # Skyfield: 2025-03-20T09:01:28.93Z
      expect(year.june_solstice.instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 6, 21, 2, 42, 15.68))
      # IMCCE:    2025-06-21T02:42:16Z
      # Skyfield: 2025-06-21T02:42:15.68Z
      expect(year.september_equinox.instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 9, 22, 18, 19, 20.50))
      # IMCCE:    2025-09-22T18:19:21Z
      # Skyfield: 2025-09-22T18:19:20.49Z
      expect(year.december_solstice.instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 12, 21, 15, 3, 5.14))
      # IMCCE:    2025-12-21T15:03:05Z
      # Skyfield: 2025-12-21T15:03:05.13Z
      expect(year.to_a.map(&:kind)).to eq(Astronoby::SeasonStart::KINDS)
    end

    it "finds them with geometric positions rounded by the cache" do
      Astronoby.configuration.cache_enabled = true
      Astronoby.configuration.cache_precision(:geometric, 5)
      sky = Astronoby::Sky.new(test_ephem)

      year = sky.seasons.in(2025)

      expect(year.june_solstice.instant.to_time)
        .to be_within(1).of(Time.utc(2025, 6, 21, 2, 42, 15.68))
    end

    it "agrees with the Sun's apparent longitude" do
      ephem = test_ephem
      sky = Astronoby::Sky.new(ephem)

      solstice = sky.seasons.in(2025).june_solstice
      longitude = Astronoby::Sun
        .new(ephem: ephem, instant: solstice.instant)
        .apparent.ecliptic.longitude

      expect(longitude.degrees).to be_within(1e-6).of(90)
    end
  end

  describe "#between" do
    it "returns the equinoxes and solstices in the range" do
      sky = Astronoby::Sky.new(test_ephem)

      starts = sky.seasons.between(Time.utc(2025, 5, 1), Time.utc(2025, 10, 1))

      expect(starts.map(&:kind)).to eq([:june_solstice, :september_equinox])
    end
  end

  describe "#on" do
    it "returns the equinox or solstice of the day" do
      sky = Astronoby::Sky.new(test_ephem)

      starts = sky.seasons.on(Date.new(2025, 3, 20))

      expect(starts.map(&:kind)).to eq([:march_equinox])
    end
  end

  describe "#from" do
    it "returns the next equinoxes and solstices" do
      sky = Astronoby::Sky.new(test_ephem)

      starts = sky.seasons
        .from(Astronoby::Instant.from_time(Time.utc(2025, 7, 1)))
        .first(2)

      expect(starts.map(&:kind)).to eq([:september_equinox, :december_solstice])
    end
  end
end
