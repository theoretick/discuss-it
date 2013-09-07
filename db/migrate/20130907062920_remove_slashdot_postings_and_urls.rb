class RemoveSlashdotPostingsAndUrls < ActiveRecord::Migration
  def change
    drop_table :slashdot_postings
    drop_table :urls
  end
end
