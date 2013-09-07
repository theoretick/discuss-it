class RemoveSlashdotPostingsUrls < ActiveRecord::Migration
  def change
    drop_table :slashdot_postings_urls
  end
end
