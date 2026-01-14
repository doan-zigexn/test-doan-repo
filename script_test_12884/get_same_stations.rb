require_relative '../../config/environment'

FIELDS = %i[id rail_code rail_name station_name station_code]
differ_count = 0

def lines_equal?(before_lines, after_lines)
  return false unless before_lines.size == after_lines.size

  before_lines_hash = before_lines.index_by{|l| l[:rail_code]}
  after_lines_hash = after_lines.index_by{|l| l[:rail_code]}

  result = true
  before_lines_hash.each do |rail_code, before_line|
    after_line = after_lines_hash[rail_code]

    if after_line.blank?
      result = false
      break
    end

    FIELDS.each do |key|
      next if after_line[key] == before_line[key]

      binding.pry
      result = false
      break
    end
  end

  result
end

RStationApi::Station.pluck(:station_code).uniq.each do |station_code|
  before_lines = StationApi.get_same_stations(station_code)
  after_lines = RStationApi::Station.get_same_stations(station_code)

  unless lines_equal?(before_lines, after_lines)
    puts "Missmatch output, station_code #{station_code}"
    differ_count += 1
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
