class Search < ActiveRecord::Base
  validates :query_url, uniqueness: true, presence: true
  has_and_belongs_to_many :users
end
