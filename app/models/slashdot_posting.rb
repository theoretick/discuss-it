class SlashdotPosting < ActiveRecord::Base
  validates :permalink, presence: true, uniqueness: true

  has_and_belongs_to_many :urls
end
