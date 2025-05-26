# frozen_string_literal: true

RSpec.describe Astronoby::Configuration do
  describe "cache configuration" do
    it "allows disabling cache" do
      Astronoby.reset_configuration!
      Astronoby.configuration.cache_enabled = false

      expect(Astronoby.cache).to be_a(Astronoby::NullCache)
    end

    it "allows configuring precision" do
      Astronoby.reset_configuration!
      Astronoby.configuration.cache_precision(:geometric, 3)

      expect(Astronoby.configuration.cache_precision(:geometric)).to eq(3)
    end

    it "maintains different precisions for different calculation types" do
      Astronoby.reset_configuration!
      instant = Astronoby::Instant.from_time(Time.now)
      key1 = Astronoby::CacheKey.generate(:geometric, instant)
      key2 = Astronoby::CacheKey.generate(:nutation, instant)

      expect(key1[1]).not_to eq(key2[1])
    end
  end
end
