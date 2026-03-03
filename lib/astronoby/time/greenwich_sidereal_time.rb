# frozen_string_literal: true

module Astronoby
  # Greenwich Sidereal Time base class. Dispatches to mean or apparent
  # subclasses.
  class GreenwichSiderealTime < SiderealTime
    # Creates a Greenwich Sidereal Time from UTC.
    #
    # @param utc [Time] the UTC time
    # @param type [Symbol] :mean or :apparent
    # @return [Astronoby::GreenwichMeanSiderealTime,
    #   Astronoby::GreenwichApparentSiderealTime]
    def self.from_utc(utc, type: MEAN)
      validate_type!(type)
      case type
      when MEAN
        GreenwichMeanSiderealTime.from_utc(utc)
      when APPARENT
        GreenwichApparentSiderealTime.from_utc(utc)
      end
    end

    # @param utc [Time] the UTC time
    # @return [Astronoby::GreenwichMeanSiderealTime]
    def self.mean_from_utc(utc)
      GreenwichMeanSiderealTime.from_utc(utc)
    end

    # @param utc [Time] the UTC time
    # @return [Astronoby::GreenwichApparentSiderealTime]
    def self.apparent_from_utc(utc)
      GreenwichApparentSiderealTime.from_utc(utc)
    end

    # Converts to UTC.
    #
    # @return [Time] the UTC time
    # @raise [NotImplementedError] if this is apparent sidereal time
    def to_utc
      unless mean?
        raise NotImplementedError,
          "UTC conversion only supported for mean sidereal time"
      end

      gmst = GreenwichMeanSiderealTime.new(date: @date, time: @time)
      gmst.to_utc
    end

    # Converts to Local Sidereal Time for a given longitude.
    #
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalMeanSiderealTime,
    #   Astronoby::LocalApparentSiderealTime]
    def to_lst(longitude:)
      LocalSiderealTime.from_gst(gst: self, longitude: longitude)
    end
  end
end
