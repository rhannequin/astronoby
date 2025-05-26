# frozen_string_literal: true

module Astronoby
  class Configuration
    DEFAULT_PRECISIONS = {
      geometric: 9,        # 8.64e-5 seconds
      nutation: 2,         # 864 seconds
      precession: 2,       # 864 seconds
      rise_transit_set: 7  # 8.64e-3 seconds
    }.freeze

    attr_accessor :cache_enabled
    attr_reader :cache_precisions

    def initialize
      @cache_enabled = false
      @cache_precisions = DEFAULT_PRECISIONS.dup
      @cache_instance = nil
    end

    # Configure cache precision for specific calculation types
    # @param type [Symbol] The calculation type
    # @param precision [Numeric] Precision in rounding of terrestrial time
    # @return [Numeric] the precision for the given type
    def cache_precision(type, precision = nil)
      if precision.nil?
        @cache_precisions[type] || DEFAULT_PRECISIONS[:geometric]
      else
        @cache_precisions[type] = precision
      end
    end

    # Set all cache precisions at once
    # @param precisions [Hash] Hash of calculation type to precision in rounding
    #   of terrestrial time
    # @return [void]
    def cache_precisions=(precisions)
      @cache_precisions = DEFAULT_PRECISIONS.merge(precisions)
    end

    # Get the cache instance (singleton or null cache)
    # @return [Astronoby::Cache, Astronoby::NullCache] the cache instance
    def cache
      @cache_instance ||= if cache_enabled
        Cache.instance
      else
        NullCache.instance
      end
    end

    # Reset cache instance (useful for testing or configuration changes)
    # @return [void]
    def reset_cache!
      @cache_instance = nil
      Cache.instance.clear if cache_enabled
    end
  end

  class << self
    # Global configuration instance
    # @return [Astronoby::Configuration] the global configuration instance
    def configuration
      @configuration ||= Configuration.new
    end

    # Configuration block for setup
    # @example
    #   Astronoby.configure do |config|
    #     config.cache_enabled = false
    #     config.cache_precision(:geometric, 9)
    #   end
    def configure
      yield(configuration)
      configuration.reset_cache!
    end

    # Quick access to cache
    # @return [Astronoby::Cache, Astronoby::NullCache] the cache instance
    def cache
      configuration.cache
    end

    # Reset configuration to defaults
    # @return [void]
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
