# frozen_string_literal: true

# TODO: This needs to be improved by receiving an instant instead of an Epoch
# as these coefficients work with TT (Terrestrial Time).

module Astronoby
  class MeanObliquity
    # Source:
    #  IAU resolution in 2006 in favor of the P03 astronomical model
    #  https://syrte.obspm.fr/iau2006/aa03_412_P03.pdf

    EPOCH_OF_REFERENCE = JulianDate::DEFAULT_EPOCH
    OBLIQUITY_OF_REFERENCE = 23.4392794

    def self.for_epoch(epoch)
      return obliquity_of_reference if epoch == EPOCH_OF_REFERENCE

      t = Rational(
        epoch - EPOCH_OF_REFERENCE,
        Constants::DAYS_PER_JULIAN_CENTURY
      )

      epsilon0 = obliquity_of_reference_in_arcseconds
      c1 = -46.836769
      c2 = -0.0001831
      c3 = 0.00200340
      c4 = -0.000000576
      c5 = -0.0000000434

      Angle.from_degree_arcseconds(
        epsilon0 + t * (c1 + t * (c2 + t * (c3 + t * (c4 + t * c5))))
      )
    end

    def self.obliquity_of_reference
      Angle.from_degree_arcseconds(obliquity_of_reference_in_arcseconds)
    end

    def self.obliquity_of_reference_in_arcseconds
      84381.406
    end
  end
end
