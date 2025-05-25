# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    Astronoby.reset_configuration!
    Astronoby.configure do |config|
      config.cache_enabled = false
    end
  end
end
