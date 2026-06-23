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

  def test_ephem_inpop
    path = File.path("#{__dir__}/data/inpop19a_2025_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end

  def test_ephem_inpop_2000_2050
    path = File.path("#{__dir__}/data/inpop19a_2000_2050_excerpt.bsp")
    Astronoby::Ephem.load(path)
  end

  def test_ephem_inpop_full
    path = File.path("#{__dir__}/data/inpop19a.bsp")
    Astronoby::Ephem.load(path)
  end

  def test_orientation
    path = File.path("#{__dir__}/data/moon_pa_de440_excerpt.bpc")
    Astronoby::Orientation.load(path)
  end
end
