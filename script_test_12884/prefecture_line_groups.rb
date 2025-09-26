require_relative '../../config/environment'

Prefecture.all.each do |pref|
  before_groups = StationApi.prefecture_line_groups(prefecture_id: pref.code)
  after_groups  = RStationApi::Station.prefecture_line_groups(prefecture_id: pref.code)

  unless before_groups == after_groups
    differ_count += 1
    puts "Mismatch output of prefecture id #{pref.code}"
  end
end

puts "===================SUMMARY==================="
puts "||                                         ||"
puts "||  There are #{differ_count} differences  ||"
puts "||                                         ||"
puts "============================================="
