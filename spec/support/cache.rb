# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    Astronoby.reset_configuration!
    Astronoby.configuration.cache_enabled = false
  end
end
