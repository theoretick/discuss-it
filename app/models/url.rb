class Url < ActiveRecord::Base
  validates :target_url, presence: true, uniqueness: true

  has_and_belongs_to_many :slashdot_postings
end
