module Astronoby
  class IncompatibleArgumentsError < ArgumentError; end

  class UnsupportedFormatError < ArgumentError; end

  class UnsupportedEventError < ArgumentError; end

  class CalculationError < StandardError; end
end
