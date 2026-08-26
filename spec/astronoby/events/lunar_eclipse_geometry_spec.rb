# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipseGeometry do
  describe "#umbral_magnitude" do
    it "is 0 when the Moon's near limb just touches the umbra" do
      moon_radius = Astronoby::Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

      geometry = geometry_with(
        umbra_radius: 5000,
        axis_distance: 5000 + moon_radius
      )

      expect(geometry.umbral_magnitude).to be_within(1e-12).of(0)
    end

    it "is 1/2 when the Moon's centre reaches the edge of the umbra" do
      geometry = geometry_with(umbra_radius: 5000, axis_distance: 5000)

      expect(geometry.umbral_magnitude).to be_within(1e-12).of(0.5)
    end

    it "is 1 when the Moon's far limb passes into the umbra" do
      moon_radius = Astronoby::Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

      geometry = geometry_with(
        umbra_radius: 5000,
        axis_distance: 5000 - moon_radius
      )

      expect(geometry.umbral_magnitude).to be_within(1e-12).of(1)
    end

    it "is negative when the Moon stays clear of the umbra" do
      moon_radius = Astronoby::Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

      geometry = geometry_with(
        umbra_radius: 5000,
        axis_distance: 5000 + 3 * moon_radius
      )

      expect(geometry.umbral_magnitude).to be_within(1e-12).of(-1)
    end
  end

  describe "#penumbral_magnitude" do
    it "is 0 when the Moon's near limb just touches the penumbra" do
      moon_radius = Astronoby::Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0

      geometry = geometry_with(
        penumbra_radius: 9000,
        axis_distance: 9000 + moon_radius
      )

      expect(geometry.penumbral_magnitude).to be_within(1e-12).of(0)
    end
  end

  describe "angular forms" do
    it "subtend angles whose sine returns the length" do
      geometry = geometry_with(
        axis_distance: 2401.3,
        umbra_radius: 4664.4,
        penumbra_radius: 8254.0,
        moon_distance: 382_600.7
      )

      expect(382_600.7 * geometry.angular_axis_distance.sin)
        .to be_within(1e-9).of(2401.3)
      expect(382_600.7 * geometry.umbra_angular_radius.sin)
        .to be_within(1e-9).of(4664.4)
      expect(382_600.7 * geometry.penumbra_angular_radius.sin)
        .to be_within(1e-9).of(8254.0)
    end
  end

  it "is immutable" do
    expect(geometry_with).to be_frozen
  end

  def geometry_with(
    axis_distance: 2401.3,
    position_angle: 208.2,
    umbra_radius: 4664.4,
    penumbra_radius: 8254.0,
    moon_distance: 382_600.7
  )
    described_class.new(
      axis_distance: Astronoby::Distance.from_kilometers(axis_distance),
      position_angle: Astronoby::Angle.from_degrees(position_angle),
      umbra_radius: Astronoby::Distance.from_kilometers(umbra_radius),
      penumbra_radius: Astronoby::Distance.from_kilometers(penumbra_radius),
      moon_distance: Astronoby::Distance.from_kilometers(moon_distance)
    )
  end
end
