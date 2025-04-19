module Astronoby
  class IncompatibleArgumentsError < ArgumentError; end

  class UnsupportedFormatError < ArgumentError; end

  class UnsupportedEventError < ArgumentError; end

  class CalculationError < StandardError; end

  class EphemerisError < StandardError; end
end
