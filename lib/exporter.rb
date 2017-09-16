require 'csv'

module Exporter

  def self.run
    Donation.states.each do |state|
      export Rails.root.join("public/data/#{state}.csv"), Donation.where(state: state)
    end
  end

  def self.export(path, donations)
    CSV.open(path, 'w') do |csv|
      generate(csv, donations)
    end
  end

  def self.generate(csv, donations)
    csv << %w(date_begin date_end state number donor recipient kind purpose amount)
    donations.find_each do |row|
      csv << %w(date_begin date_end state number donor recipient_name kind purpose amount).map{|key| row.send(key) }
    end
  end

end
