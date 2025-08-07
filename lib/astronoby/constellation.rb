# frozen_string_literal: true

module Astronoby
  class Constellation
    attr_reader :name, :abbreviation

    def initialize(name, abbreviation)
      @name = name
      @abbreviation = abbreviation
    end
  end
end
