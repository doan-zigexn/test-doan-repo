require_relative '../../config/environment'

line_codes = RStationApi::Railroad.pluck(:code)
differ_count = 0

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

line_codes.each do |line_code|
  before_stations = StationApi.line_stations(line_code: line_code)
  after_stations = RStationApi::Station.line_stations(line_code: line_code)

  unless stations_equal?(before_stations, after_stations)
    differ_count += 1
    puts "Mismatch output: #{line_code}"
  end
end

puts "There are #{differ_count} differences"
