require_relative '../../config/environment'

target_file = "#{Rails.root}/db/statics/prefecture_top/pickup_stations.yml"
pickup_stations = YAML.load_file(target_file)
differ_count = 0

pickup_stations.each do |prefecture_id, stations|
  stations.each do |station|
    next if station["station_name"].blank?

    before_station = StationApi.find_by_fuzzy_names(
      station_names: [station["station_name"]],
      prefecture_code: prefecture_id
    )

    after_station = RStationApi::Station.find_by_fuzzy_names(
      station_names: [station["station_name"]],
      prefecture_code: prefecture_id
    )

    is_equal = true
    before_station.except(%i[created_at updated_at :deleted_at]).each do |key, value|
      next if value == after_station[key]

      is_equal = false
      break
    end

    unless is_equal
      puts "Mismatch output: #{station["station_name"]}."
      differ_count += 1
    end
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
