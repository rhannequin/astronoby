module Astronoby
  # Raised when arguments are mutually incompatible.
  class IncompatibleArgumentsError < ArgumentError; end

  # Raised when an unsupported format is requested.
  class UnsupportedFormatError < ArgumentError; end

  # Raised when an unsupported event type is requested.
  class UnsupportedEventError < ArgumentError; end

  # Raised when an astronomical calculation fails.
  class CalculationError < StandardError; end

  # Raised when there is an error with ephemeris data.
  class EphemerisError < StandardError; end

  # Raised when an orientation kernel is not a supported orientation source.
  class OrientationError < StandardError; end

  # Raised when an orientation kernel does not cover the requested instant.
  class OrientationOutOfRangeError < StandardError; end
end
