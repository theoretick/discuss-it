class AddPostDateToSlashdotPostings < ActiveRecord::Migration
  def change
    add_column :slashdot_postings, :post_date, :string
  end
end
