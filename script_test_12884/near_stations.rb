require_relative '../../config/environment'

FIELDS = %i[
  lat lon station_sort station_group_code line_code
  station_name station_code ekitan_station_code
  prefecture_id line_sort
]

differ_count = 0

def is_equal?(city)
  result = true

  lat = city.latitude
  lon = city.longitude

  stations_from_api = StationApi.near_stations(lat: lat, lon: lon)
  stations_from_db  = RStationApi::Station.near_stations(lat: lat, lon: lon).index_by(&:id)

  stations_from_api.each do |api|
    id = api[:id]
    db = stations_from_db[id]

    if db.blank?
      result = false
      break
    end

    FIELDS.each do |key|
      next if api[key] == db[key]

      result = false
      break
    end

    break unless result
  end

  result
end

SumaiApi::City.with_coordinates.each do |city|
  unless is_equal?(city)
    puts "Stations near city #{city.code} from API differs from database"
    differ_count += 1
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
