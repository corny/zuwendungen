# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Rails.root.join("lib/source").children.each do |child|
  require child
end

Source::Base.subclasses.each do |sub|
  source = sub.new
  puts "[#{sub}] Downloading"
  source.download_all
  puts "[#{sub}] Importing"
  source.import_all
end
