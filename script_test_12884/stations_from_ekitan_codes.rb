require_relative '../../config/environment'

differ_count = 0
ekitan_station_codes = RStationApi::Station.pluck(:ekitan_station_code).uniq

def stations_equal?(bf_stations, af_stations)
  return false unless bf_stations.size == af_stations.size

  bf_stations_hash = bf_stations.index_by{|s| s[:station_code]}
  af_stations_hash = af_stations.index_by{|s| s[:station_code]}

  result = true
  bf_stations_hash.each do |station_code, bf_station|
    af_station = af_stations_hash[station_code]

    if af_station.blank?
      result = false
      break
    end

    bf_station.except(:created_at, :updated_at, :deleted_at).each do |key, value|
      next if value == af_station[key]

      result = false
      break
    end

    break unless result
  end

  result
end

ekitan_station_codes.each do |ekitan_station_code|
  before_stations = StationApi.stations_from_ekitan_codes([ekitan_station_code])
  after_stations  = RStationApi::Station.stations_from_ekitan_codes([ekitan_station_code])

  unless stations_equal?(before_stations, after_stations)
    puts "Mismatch output ekitan_station_code: #{ekitan_station_code}"
    differ_count += 1
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
