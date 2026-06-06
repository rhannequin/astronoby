# frozen_string_literal: true

RSpec.describe Astronoby::Body do
  it "is fulfilled by solar system body classes" do
    expect(Astronoby::Saturn).to be_a(described_class)
    expect(Astronoby::Moon).to be_a(described_class)
  end

  it "is fulfilled by deep-sky objects" do
    deep_sky_object = Astronoby::DeepSkyObject.new(
      equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.zero
      )
    )

    expect(deep_sky_object).to be_a(described_class)
  end
end
