# frozen_string_literal: true

module TestEphemHelper
  def test_ephem
    path = File.path("#{__dir__}/data/de440s_2025_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end
end
