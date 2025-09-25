require_relative '../../config/environment'

LINE_FIELDS = %i[code name nickname sort_order]

differ_count = 0

def group_equal?(bf_group, af_group)
  return false if bf_group.blank? || af_group.blank?
  return false if bf_group[:name] != af_group[:name] || bf_group[:group_code] != af_group[:group_code]

  bf_lines = bf_group[:lines]
  af_lines = af_group[:lines]
  return false if bf_lines.size != af_lines.size

  result = true
  bf_lines.each_with_index do |bf_line, index|
    af_line = af_lines[index]

    LINE_FIELDS.each do |key|
      next if af_line[key] == bf_line[key]

      result = false
      break
    end

    break unless result
  end

  result
end

def groups_equal?(bf_groups, af_groups)
  return false unless bf_groups.size == af_groups.size

  bf_groups_hash = bf_groups.index_by{|g| g[:group_code]}
  af_groups_hash = af_groups.index_by{|g| g[:group_code]}
  result = true

  bf_groups_hash.each do |group_code, bf_group|
    af_group = af_groups_hash[group_code]

    unless group_equal?(bf_group, af_group)
      result = false
      break
    end
  end
end

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
