require_relative '../../config/environment'

FIELDS = %i[code name nickname]

differ_count = 0

RStationApi::Railroad.all.each do |line|
  before_line = StationApi.line_name(line_code: line.code)
  after_line  = RStationApi::Station.line_name(line_code: line.code)

  is_equal = true
  FIELDS.each do |field|
    next if before_line[field] == after_line[field]

    is_equal = false
    break
  end

  unless is_equal
    puts "Line #{line.code} from Api differs from db"
    differ_count += 1
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
