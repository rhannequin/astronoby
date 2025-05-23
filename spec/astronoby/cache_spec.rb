# frozen_string_literal: true

RSpec.describe Astronoby::Cache do
  describe "::instance" do
    it "returns the same instance every time" do
      instance1 = described_class.instance
      instance2 = described_class.instance

      expect(instance1).to equal(instance2)
    end
  end

  describe "#[] and #[]=" do
    it "stores and retrieves values for the same key" do
      cache = described_class.instance
      cache.clear
      cache["foo"] = "bar"

      expect(cache["foo"]).to eq "bar"
    end

    it "returns nil for unknown keys" do
      cache = described_class.instance
      cache.clear

      expect(cache["missing"]).to be_nil
    end

    it "overwrites an existing key" do
      cache = described_class.instance
      cache.clear
      cache["a"] = 1
      cache["a"] = 2

      expect(cache["a"]).to eq 2
    end

    it "moves accessed keys to the head (most recently used)" do
      cache = described_class.instance
      cache.clear
      cache["a"] = 1
      cache["b"] = 2
      cache["c"] = 3

      expect(cache["a"]).to eq 1
      expect(cache["b"]).to eq 2
    end
  end

  describe "#fetch" do
    it "returns the value for an existing key without yielding" do
      cache = described_class.instance
      cache.clear
      cache["cat"] = "meow"
      block_called = false

      result = cache.fetch("cat") do
        block_called = true
        "fail"
      end

      expect(result).to eq "meow"
      expect(block_called).to be false
    end

    it "stores and returns the block value when the key is missing" do
      cache = described_class.instance
      cache.clear
      block_run = false

      value = cache.fetch("newkey") do
        block_run = true
        "computed"
      end

      expect(value).to eq "computed"
      expect(block_run).to be true
      expect(cache["newkey"]).to eq "computed"
    end
  end

  describe "LRU eviction" do
    it "evicts the least recently used item when full" do
      cache = described_class.instance
      cache.clear
      original_max_size = cache.max_size
      cache.max_size = 3

      cache["a"] = 1
      cache["b"] = 2
      cache["c"] = 3

      expect(cache.size).to eq 3

      cache["a"]
      cache["d"] = 4

      expect(cache["a"]).to eq 1
      expect(cache["c"]).to eq 3
      expect(cache["d"]).to eq 4
      expect(cache["b"]).to be_nil
      expect(cache.size).to eq 3

      cache.max_size = original_max_size
      cache.clear
    end

    it "evicts multiple items if max_size is decreased" do
      cache = described_class.instance
      cache.clear
      original_max_size = cache.max_size
      cache.max_size = 5

      5.times { |i| cache[i] = i }
      expect(cache.size).to eq 5
      cache.max_size = 2
      expect(cache.size).to eq 2

      expect(cache[4]).to eq 4
      expect(cache[3]).to eq 3
      expect(cache[2]).to be_nil
      expect(cache[1]).to be_nil
      expect(cache[0]).to be_nil

      cache.max_size = original_max_size
      cache.clear
    end

    it "raises ArgumentError if max_size set to zero or negative" do
      cache = described_class.instance
      cache.clear

      expect { cache.max_size = 0 }.to raise_error(ArgumentError)
      expect { cache.max_size = -5 }.to raise_error(ArgumentError)
    end
  end

  describe "#clear" do
    it "removes all entries from the cache" do
      cache = described_class.instance
      cache["a"] = "b"
      cache["c"] = "d"

      expect(cache.size).to be > 0

      cache.clear

      expect(cache.size).to eq 0
      expect(cache["a"]).to be_nil
      expect(cache["c"]).to be_nil
    end
  end

  describe "#size" do
    it "returns the number of items in the cache" do
      cache = described_class.instance
      cache.clear
      cache["x"] = 10
      cache["y"] = 20

      expect(cache.size).to eq 2
    end
  end
end
