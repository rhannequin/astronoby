# frozen_string_literal: true

require "monitor"
require "singleton"

module Astronoby
  class Cache
    include Singleton

    Entry = Struct.new(:key, :value, :prev, :next)

    DEFAULT_MAX_SIZE = 10_000

    attr_reader :max_size

    # @param max_size [Integer] Maximum number of entries allowed in the cache
    # @return [void]
    def initialize(max_size = DEFAULT_MAX_SIZE)
      @max_size = max_size
      @hash = {}
      @head = nil
      @tail = nil
      @mutex = Monitor.new
    end

    # @param key [Object] the cache key
    # @return [Object, nil] the value, or nil if not found
    def [](key)
      @mutex.synchronize do
        entry = @hash[key]
        if entry
          move_to_head(entry)
          entry.value
        end
      end
    end

    # @param key [Object]
    # @param value [Object]
    # @return [Object] the value set
    def []=(key, value)
      @mutex.synchronize do
        entry = @hash[key]
        if entry
          entry.value = value
          move_to_head(entry)
        else
          entry = Entry.new(key, value)
          add_to_head(entry)
          @hash[key] = entry
          evict_last_recently_used if @hash.size > @max_size
        end
      end
    end

    # @param key [Object]
    # @yieldreturn [Object] Value to store if key is missing.
    # @return [Object] Cached or computed value.
    def fetch(key)
      return self[key] if @mutex.synchronize { @hash.key?(key) }

      value = yield

      @mutex.synchronize do
        self[key] = value unless @hash.key?(key)
      end

      value
    end

    # @return [void]
    def clear
      @mutex.synchronize do
        @hash.clear
        @head = @tail = nil
      end
    end

    # @return [Integer]
    def size
      @mutex.synchronize { @hash.size }
    end

    # @param new_size [Integer] the new cache limit.
    # @return [void]
    def max_size=(new_size)
      raise ArgumentError, "max_size must be positive" unless new_size > 0
      @mutex.synchronize do
        @max_size = new_size
        while @hash.size > @max_size
          evict_last_recently_used
        end
      end
    end

    private

    def add_to_head(entry)
      entry.prev = nil
      entry.next = @head
      @head.prev = entry if @head
      @head = entry
      @tail ||= entry
    end

    def move_to_head(entry)
      return if @head == entry

      # Unlink
      entry.prev.next = entry.next if entry.prev
      entry.next.prev = entry.prev if entry.next

      # Update tail if needed
      @tail = entry.prev if @tail == entry

      # Insert as new head
      entry.prev = nil
      entry.next = @head
      @head.prev = entry if @head
      @head = entry
    end

    def evict_last_recently_used
      if @tail
        @hash.delete(@tail.key)
        if @tail.prev
          @tail = @tail.prev
          @tail.next = nil
        else
          @head = @tail = nil
        end
      end
    end
  end
end
