# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

require "astronoby"

require "support/test_ephem_helper"
require "support/cache"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do |example|
    if example.metadata[:deprecations]
      Astronoby::Deprecation.reset
    else
      allow(Astronoby::Deprecation).to receive(:warn) do |*, uplevel: 1|
        next if Thread.current[Astronoby::Deprecation::NESTED_KEY]

        call_site = caller_locations
          .reject { |location| location.path.include?("/rspec-") }[uplevel]
        if call_site&.path&.include?("/lib/astronoby/")
          raise "Deprecated method called from the library at #{call_site}"
        end
      end
    end
  end
end
