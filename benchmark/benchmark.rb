require "astronoby"
require "csv"
require "zip"

class Result
  attr_accessor :sun_rising_time,
    :sun_transit_time,
    :sun_setting_time,
    :moon_rising_time,
    :moon_transit_time,
    :moon_setting_time,
    :illuminated_fraction,
    :sun_rising_time_too_far,
    :sun_transit_time_too_far,
    :sun_setting_time_too_far,
    :moon_rising_time_too_far,
    :moon_transit_time_too_far,
    :moon_setting_time_too_far

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

  def display
    puts "Sun rising time:"
    tally(sun_rising_time)
    puts "Sun transit time:"
    tally(sun_transit_time)
    puts "Sun setting time:"
    tally(sun_setting_time)
    puts "Moon rising time:"
    tally(moon_rising_time)
    puts "Moon transit time:"
    tally(moon_transit_time)
    puts "Moon setting time:"
    tally(moon_setting_time)
    puts "Moon illuminated fraction:"
    tally(illuminated_fraction)
    puts "Sun rising time too far:"
    tally(sun_rising_time_too_far)
    puts "Sun transit time too far:"
    tally(sun_transit_time_too_far)
    puts "Sun setting time too far:"
    tally(sun_setting_time_too_far)
    puts "Moon rising time too far:"
    tally(moon_rising_time_too_far)
    puts "Moon transit time too far:"
    tally(moon_transit_time_too_far)
    puts "Moon setting time too far:"
    tally(moon_setting_time_too_far)
  end

  private

  def tally(data)
    t = data.tally
    t.values.sum
    t.each do |key, value|
      puts "#{key}: #{value} (#{(value.to_f / t.values.sum * 100).round(2)}%)"
    end
    puts "\n"
  end
end

class Comparison
  SUN_CALC = "sun_calc"
  ASTRONOBY = "astronoby"
  NON_APPLICABLE = "n/a"

  TOO_FAR_THRESHOLD = 60 * 5 # 5 minutes

  attr_accessor :sun_calc_sun_rising_time,
    :sun_calc_sun_transit_time,
    :sun_calc_sun_setting_time,
    :sun_calc_moon_rising_time,
    :sun_calc_moon_transit_time,
    :sun_calc_moon_setting_time,
    :sun_calc_moon_illuminated_fraction,
    :imcce_sun_rising_time,
    :imcce_sun_transit_time,
    :imcce_sun_setting_time,
    :imcce_moon_rising_time,
    :imcce_moon_transit_time,
    :imcce_moon_setting_time,
    :imcce_moon_illuminated_fraction,
    :astronoby_sun_rising_time,
    :astronoby_sun_transit_time,
    :astronoby_sun_setting_time,
    :astronoby_moon_rising_time,
    :astronoby_moon_transit_time,
    :astronoby_moon_setting_time,
    :astronoby_moon_illuminated_fraction

  def closest_sun_rising_time
    compare(imcce_sun_rising_time, sun_calc_sun_rising_time, astronoby_sun_rising_time)
  end

  def closest_sun_transit_time
    compare(imcce_sun_transit_time, sun_calc_sun_transit_time, astronoby_sun_transit_time)
  end

  def closest_sun_setting_time
    compare(imcce_sun_setting_time, sun_calc_sun_setting_time, astronoby_sun_setting_time)
  end

  def closest_moon_rising_time
    compare(imcce_moon_rising_time, sun_calc_moon_rising_time, astronoby_moon_rising_time)
  end

  def closest_moon_transit_time
    compare(imcce_moon_transit_time, sun_calc_moon_transit_time, astronoby_moon_transit_time)
  end

  def closest_moon_setting_time
    compare(imcce_moon_setting_time, sun_calc_moon_setting_time, astronoby_moon_setting_time)
  end

  def closest_moon_illuminated_fraction
    compare(
      imcce_moon_illuminated_fraction,
      sun_calc_moon_illuminated_fraction,
      astronoby_moon_illuminated_fraction
    )
  end

  def sun_rising_time_too_far?
    return false unless imcce_sun_rising_time && astronoby_sun_rising_time

    (imcce_sun_rising_time - astronoby_sun_rising_time).abs > TOO_FAR_THRESHOLD
  end

  def sun_transit_time_too_far?
    return false unless imcce_sun_transit_time && astronoby_sun_transit_time

    (imcce_sun_transit_time - astronoby_sun_transit_time).abs > TOO_FAR_THRESHOLD
  end

  def sun_setting_time_too_far?
    return false unless imcce_sun_setting_time && astronoby_sun_setting_time

    (imcce_sun_setting_time - astronoby_sun_setting_time).abs > TOO_FAR_THRESHOLD
  end

  def moon_rising_time_too_far?
    return false unless imcce_moon_rising_time && astronoby_moon_rising_time

    (imcce_moon_rising_time - astronoby_moon_rising_time).abs > TOO_FAR_THRESHOLD
  end

  def moon_transit_time_too_far?
    return false unless imcce_moon_transit_time && astronoby_moon_transit_time

    (imcce_moon_transit_time - astronoby_moon_transit_time).abs > TOO_FAR_THRESHOLD
  end

  def moon_setting_time_too_far?
    return false unless imcce_moon_setting_time && astronoby_moon_setting_time

    (imcce_moon_setting_time - astronoby_moon_setting_time).abs > TOO_FAR_THRESHOLD
  end

  private

  def compare(imcce, sun_calc, astronoby)
    return NON_APPLICABLE unless imcce && sun_calc && astronoby

    sun_calc_diff = (imcce - sun_calc).abs
    astronoby_diff = (imcce - astronoby).abs
    (sun_calc_diff < astronoby_diff) ? SUN_CALC : ASTRONOBY
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
      comparison.sun_calc_sun_rising_time = Time.new(row["sun_rising_time"]) if row["sun_rising_time"]
      comparison.sun_calc_sun_transit_time = Time.new(row["sun_transit_time"]) if row["sun_transit_time"]
      comparison.sun_calc_sun_setting_time = Time.new(row["sun_setting_time"]) if row["sun_setting_time"]
      comparison.sun_calc_moon_rising_time = Time.new(row["moon_rising_time"]) if row["moon_rising_time"]
      comparison.sun_calc_moon_transit_time = Time.new(row["moon_transit_time"]) if row["moon_transit_time"]
      comparison.sun_calc_moon_setting_time = Time.new(row["moon_setting_time"]) if row["moon_setting_time"]
      comparison.sun_calc_moon_illuminated_fraction = row["illuminated_fraction"].to_f
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
    comparison.imcce_sun_rising_time = Time.new(row["sun_rising_time"] + " UTC") if row["sun_rising_time"]
    comparison.imcce_sun_transit_time = Time.new(row["sun_transit_time"] + " UTC") if row["sun_transit_time"]
    comparison.imcce_sun_setting_time = Time.new(row["sun_setting_time"] + " UTC") if row["sun_setting_time"]
    comparison.imcce_moon_rising_time = Time.new(row["moon_rising_time"] + " UTC") if row["moon_rising_time"]
    comparison.imcce_moon_transit_time = Time.new(row["moon_transit_time"] + " UTC") if row["moon_transit_time"]
    comparison.imcce_moon_setting_time = Time.new(row["moon_setting_time"] + " UTC") if row["moon_setting_time"]
    comparison.imcce_moon_illuminated_fraction = row["illuminated_fraction"].to_f
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

      comparison.astronoby_sun_rising_time = sun_observation_events.rising_time
      comparison.astronoby_sun_transit_time = sun_observation_events.transit_time
      comparison.astronoby_sun_setting_time = sun_observation_events.setting_time
      comparison.astronoby_moon_rising_time = moon_observation_events.rising_time
      comparison.astronoby_moon_transit_time = moon_observation_events.transit_time
      comparison.astronoby_moon_setting_time = moon_observation_events.setting_time
      comparison.astronoby_moon_illuminated_fraction = moon.illuminated_fraction

      result.sun_rising_time << comparison.closest_sun_rising_time
      result.sun_transit_time << comparison.closest_sun_transit_time
      result.sun_setting_time << comparison.closest_sun_setting_time
      result.moon_rising_time << comparison.closest_moon_rising_time
      result.moon_transit_time << comparison.closest_moon_transit_time
      result.moon_setting_time << comparison.closest_moon_setting_time
      result.illuminated_fraction << comparison.closest_moon_illuminated_fraction
      result.sun_rising_time_too_far << comparison.sun_rising_time_too_far?
      result.sun_transit_time_too_far << comparison.sun_transit_time_too_far?
      result.sun_setting_time_too_far << comparison.sun_setting_time_too_far?
      result.moon_rising_time_too_far << comparison.moon_rising_time_too_far?
      result.moon_transit_time_too_far << comparison.moon_transit_time_too_far?
      result.moon_setting_time_too_far << comparison.moon_setting_time_too_far?
    end
  end

  puts "#{date}: Done."
end

puts "Done comparing data."
puts
puts

puts result.display
