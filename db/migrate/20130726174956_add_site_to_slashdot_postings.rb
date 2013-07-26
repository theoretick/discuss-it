class AddSiteToSlashdotPostings < ActiveRecord::Migration
  def change
    add_column :slashdot_postings, :site, :string
  end
end
