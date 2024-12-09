require "astronoby"
require "csv"
require "zip"

class Source
  NAMES = [
    ASTRONOBY = "astronoby",
    IMCCE = "imcce",
    SUN_CALC = "sun_calc"
  ].freeze

  attr_accessor :name,
    :sun_rising_time,
    :sun_transit_time,
    :sun_setting_time,
    :moon_rising_time,
    :moon_transit_time,
    :moon_setting_time,
    :moon_illuminated_fraction
end

class Comparison
  SUN_CALC = "sun_calc"
  ASTRONOBY = "astronoby"
  NON_APPLICABLE = "n/a"

  TOO_FAR_THRESHOLD = 60 * 5 # 5 minutes

  attr_accessor :sources, :truth

  def initialize
    @sources = []
  end

  %i[
    sun_rising_time
    sun_transit_time
    sun_setting_time
    moon_rising_time
    moon_transit_time
    moon_setting_time
  ].each do |attribute|
    define_method(:"closest_#{attribute}") do
      compare(attribute)
    end

    define_method(:"#{attribute}_too_far?") do
      too_far?(attribute)
    end
  end

  def closest_moon_illuminated_fraction
    compare(:moon_illuminated_fraction)
  end

  private

  def compare(attribute)
    unless truth.public_send(attribute) && sources.all? { |source| source.public_send(attribute) }
      return NON_APPLICABLE
    end

    closest_source = sources.min_by do |source|
      (truth.public_send(attribute) - source.public_send(attribute)).abs
    end

    closest_source.name
  end

  def too_far?(attribute)
    truth_attribute = truth.public_send(attribute)
    astronoby_attribute = sources
      .find { _1.name == Source::ASTRONOBY }
      .public_send(attribute)

    return false unless truth_attribute && astronoby_attribute

    (truth_attribute - astronoby_attribute).abs > TOO_FAR_THRESHOLD
  end
end

class Result
  def initialize
    @sun_rising_time = []
    @sun_transit_time = []
    @sun_setting_time = []
    @moon_rising_time = []
    @moon_transit_time = []
    @moon_setting_time = []
    @illuminated_fraction = []
    @sun_rising_time_too_far = []
    @sun_transit_time_too_far = []
    @sun_setting_time_too_far = []
    @moon_rising_time_too_far = []
    @moon_transit_time_too_far = []
    @moon_setting_time_too_far = []
  end

  def add_comparison(comparison)
    @sun_rising_time << comparison.closest_sun_rising_time
    @sun_transit_time << comparison.closest_sun_transit_time
    @sun_setting_time << comparison.closest_sun_setting_time
    @moon_rising_time << comparison.closest_moon_rising_time
    @moon_transit_time << comparison.closest_moon_transit_time
    @moon_setting_time << comparison.closest_moon_setting_time
    @illuminated_fraction << comparison.closest_moon_illuminated_fraction
    @sun_rising_time_too_far << comparison.sun_rising_time_too_far?
    @sun_transit_time_too_far << comparison.sun_transit_time_too_far?
    @sun_setting_time_too_far << comparison.sun_setting_time_too_far?
    @moon_rising_time_too_far << comparison.moon_rising_time_too_far?
    @moon_transit_time_too_far << comparison.moon_transit_time_too_far?
    @moon_setting_time_too_far << comparison.moon_setting_time_too_far?
  end

  def display
    puts "Sun rising time:"
    tally(@sun_rising_time)
    puts "Sun transit time:"
    tally(@sun_transit_time)
    puts "Sun setting time:"
    tally(@sun_setting_time)
    puts "Moon rising time:"
    tally(@moon_rising_time)
    puts "Moon transit time:"
    tally(@moon_transit_time)
    puts "Moon setting time:"
    tally(@moon_setting_time)
    puts "Moon illuminated fraction:"
    tally(@illuminated_fraction)
    puts "Sun rising time too far:"
    tally(@sun_rising_time_too_far)
    puts "Sun transit time too far:"
    tally(@sun_transit_time_too_far)
    puts "Sun setting time too far:"
    tally(@sun_setting_time_too_far)
    puts "Moon rising time too far:"
    tally(@moon_rising_time_too_far)
    puts "Moon transit time too far:"
    tally(@moon_transit_time_too_far)
    puts "Moon setting time too far:"
    tally(@moon_setting_time_too_far)
  end

  private

  def tally(data)
    t = data.tally
    t.sort_by { |_key, value| -value }.each do |key, value|
      puts "#{key}: #{value} (#{(value.to_f / t.values.sum * 100).round(2)}%)"
    end
    puts "\n"
  end
end

data = {}
result = Result.new

sun_calc_zip_file = File.join(File.dirname(__FILE__), "data/sun_calc.csv.zip")
imcce_zip_file = File.join(File.dirname(__FILE__), "data/imcce.csv.zip")

puts "Unarchiving sun_calc.csv.zip..."

Zip::File.open(sun_calc_zip_file) do |zip_file|
  puts "Done unarchiving sun_calc.csv.zip."

  csv_file = zip_file.find { |entry| entry.name.end_with?(".csv") }
  break unless csv_file

  puts "Parsing sun_calc.csv..."

  csv_content = csv_file.get_input_stream.read
  CSV.parse(csv_content, headers: true) do |row|
    data[row["date"]] ||= {}
    data[row["date"]][row["latitude"]] ||= {}
    data[row["date"]][row["latitude"]][row["longitude"]] = Comparison.new.tap do |comparison|
      source = Source.new.tap do |source|
        source.name = Source::SUN_CALC
        source.sun_rising_time = Time.new(row["sun_rising_time"]) if row["sun_rising_time"]
        source.sun_transit_time = Time.new(row["sun_transit_time"]) if row["sun_transit_time"]
        source.sun_setting_time = Time.new(row["sun_setting_time"]) if row["sun_setting_time"]
        source.moon_rising_time = Time.new(row["moon_rising_time"]) if row["moon_rising_time"]
        source.moon_transit_time = Time.new(row["moon_transit_time"]) if row["moon_transit_time"]
        source.moon_setting_time = Time.new(row["moon_setting_time"]) if row["moon_setting_time"]
        source.moon_illuminated_fraction = row["illuminated_fraction"].to_f
      end
      comparison.sources << source
    end
  end

  puts "Done parsing sun_calc.csv."
end

puts "Unarchiving imcce.csv.zip..."

Zip::File.open(imcce_zip_file) do |zip_file|
  puts "Done unarchiving imcce.csv.zip."

  csv_file = zip_file.find { |entry| entry.name.end_with?(".csv") }
  break unless csv_file

  puts "Parsing imcce.csv..."

  csv_content = csv_file.get_input_stream.read
  CSV.parse(csv_content, headers: true) do |row|
    comparison = data[row["date"]][row["latitude"]][row["longitude"]]
    comparison.truth = Source.new.tap do |source|
      source.name = Source::IMCCE
      source.sun_rising_time = Time.new(row["sun_rising_time"] + " UTC") if row["sun_rising_time"]
      source.sun_transit_time = Time.new(row["sun_transit_time"] + " UTC") if row["sun_transit_time"]
      source.sun_setting_time = Time.new(row["sun_setting_time"] + " UTC") if row["sun_setting_time"]
      source.moon_rising_time = Time.new(row["moon_rising_time"] + " UTC") if row["moon_rising_time"]
      source.moon_transit_time = Time.new(row["moon_transit_time"] + " UTC") if row["moon_transit_time"]
      source.moon_setting_time = Time.new(row["moon_setting_time"] + " UTC") if row["moon_setting_time"]
      source.moon_illuminated_fraction = row["illuminated_fraction"].to_f
    end
  end

  puts "Done parsing imcce.csv."
end

puts "Comparing data..."

data.each do |date, latitudes|
  latitudes.each do |latitude, longitudes|
    longitudes.each do |longitude, comparison|
      noon = Time.new("#{date}T12:00:00Z")
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(latitude.to_i),
        longitude: Astronoby::Angle.from_degrees(longitude.to_i)
      )
      sun = Astronoby::Sun.new(time: noon)
      sun_observation_events = sun.observation_events(observer: observer)
      moon = Astronoby::Moon.new(time: noon)
      moon_observation_events = moon.observation_events(observer: observer)

      source = Source.new.tap do |source|
        source.name = Source::ASTRONOBY
        source.sun_rising_time = sun_observation_events.rising_time
        source.sun_transit_time = sun_observation_events.transit_time
        source.sun_setting_time = sun_observation_events.setting_time
        source.moon_rising_time = moon_observation_events.rising_time
        source.moon_transit_time = moon_observation_events.transit_time
        source.moon_setting_time = moon_observation_events.setting_time
        source.moon_illuminated_fraction = moon.illuminated_fraction
      end

      comparison.sources << source
      result.add_comparison(comparison)
    end
  end

  puts "#{date}: Done."
end

puts "Done comparing data."
puts
puts

puts result.display
