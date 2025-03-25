# frozen_string_literal: true

module TestEphemHelper
  def test_ephem
    path = File.path("#{__dir__}/data/de440s_2025_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end

  def test_ephem_moon
    path = File.path("#{__dir__}/data/de440s_moon_2000_2030_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end

  def test_ephem_sun
    path = File.path("#{__dir__}/data/de440s_sun_2000_2030_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end
end
