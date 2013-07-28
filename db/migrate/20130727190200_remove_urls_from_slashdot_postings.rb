class RemoveUrlsFromSlashdotPostings < ActiveRecord::Migration
  def change
    remove_column :slashdot_postings, :urls
  end
end
