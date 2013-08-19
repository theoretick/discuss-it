class Search < ActiveRecord::Base
  validates :query_url, uniqueness: true, presence: true
  belongs_to :user
end
