# frozen_string_literal: true

module Astronoby
  module Events
    # The events of one phenomenon over time, read with #on, #between or
    # #from. Nothing is searched until one of them is called.
    class Series
      # @api private
      def initialize(window:, horizon:, time_of:, last_tt: nil, &search)
        @window = window
        @horizon = horizon
        @last_tt = last_tt
        @time_of = time_of
        @search = search
      end

      # @param start_time [Astronoby::Instant, Time] start of the range
      # @param end_time [Astronoby::Instant, Time] end of the range, included
      # @return [Array] the events in the range, sorted by time
      def between(start_time, end_time)
        events_in(
          Instant.from(start_time),
          Instant.from(end_time),
          include_end: true
        )
      end

      # @param date [Date] the civil day
      # @param utc_offset [String, Integer] UTC offset of the civil day, e.g.
      #   "+02:00"
      # @return [Array] the events from midnight to the next midnight, sorted
      #   by time
      def on(date, utc_offset: 0)
        following = date.next_day
        events_in(
          midnight(date, utc_offset),
          midnight(following, utc_offset),
          include_end: false
        )
      end

      # Searches one window at a time, as the events are asked for. Stops at
      # the end of the ephemeris or after the horizon: a year for a local sky,
      # a hundred years for the events seen from the centre of the Earth.
      #
      # @param start_time [Astronoby::Instant, Time] start of the search
      # @return [Enumerator::Lazy] the events from that time on
      # @raise [::Ephem::OutOfRangeError] if the ephemeris does not cover the
      #   start of the search
      def from(start_time)
        start_tt = Instant.from(start_time).tt
        limit = start_tt + @horizon
        if @last_tt
          if start_tt > @last_tt
            raise ::Ephem::OutOfRangeError.new(
              "The ephemeris ends before #{start_time}",
              start_tt
            )
          end
          limit = [limit, @last_tt].min
        end

        Enumerator.new do |yielder|
          window_start = start_tt
          while window_start < limit
            window_end = [window_start + @window, limit].min
            begin
              events = events_in(
                Instant.from_terrestrial_time(window_start),
                Instant.from_terrestrial_time(window_end),
                include_end: false
              )
            rescue ::Ephem::OutOfRangeError
              raise if window_start == start_tt

              break
            end
            events.each { |event| yielder << event }
            window_start = window_end
          end
        end.lazy
      end

      def inspect
        "#<#{self.class}>"
      end

      private

      def events_in(start_instant, end_instant, include_end:)
        @search
          .call(start_instant, end_instant)
          .map { |event| [@time_of.call(event), event] }
          .select do |instant, _|
            instant >= start_instant &&
              (include_end ? instant <= end_instant : instant < end_instant)
          end
          .sort_by(&:first)
          .map(&:last)
      end

      def midnight(date, utc_offset)
        Instant.from_time(
          Time.new(date.year, date.month, date.day, 0, 0, 0, utc_offset)
        )
      end
    end
  end
end
