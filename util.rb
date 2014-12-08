def dict_to_pretty_tag_list dict
  result = ''
  dict.to_a.each {|tag|
    if result != ''
      result << '; '
    end
    result << "#{tag[0]}='#{tag[1]}'"
  }
  return result
end