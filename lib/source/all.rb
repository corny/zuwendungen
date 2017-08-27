Pathname.new(__dir__).children.each do |entry|
  require entry.to_s
end
