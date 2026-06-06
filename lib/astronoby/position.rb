# frozen_string_literal: true

module Astronoby
  module Position
    # @param observer [Astronoby::Observer] the observer
    # @return [Astronoby::Topocentric] the topocentric reference frame
    def observed_by(observer)
      Topocentric.build_from_apparent(
        apparent: apparent,
        observer: observer,
        instant: instant,
        target_body: body
      )
    end
  end
end
