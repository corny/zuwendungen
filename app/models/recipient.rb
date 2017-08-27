class Recipient < ApplicationRecord

  has_many :donations

  def self.get(name)
    name = name.gsub(/\([^\)]*\)/,"").squish

    # e. V.  => e.V.
    # e. G.  => e.G.
    name.sub!(/e\. (\w)\./,"e.\\1.")
    name.sub!("Gesellschaft mit beschränkter Haftung","GmbH")
    name.sub!("Gesellschaft mbH","GmbH")
    return if name.blank?

    slug = name.parameterize.sub("-aktiengesellschaft","-ag")
    find_by(slug: slug) || create!(slug: slug, name: name)
  end

  def to_s
    name
  end

end
