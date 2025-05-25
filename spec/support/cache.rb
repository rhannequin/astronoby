# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    Astronoby::Cache.instance.clear
  end
end
