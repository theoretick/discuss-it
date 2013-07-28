class SlashdotPostingsHaveAndBelongToManyUrls < ActiveRecord::Migration

  def change
    create_table :slashdot_postings_urls, :id => false do |t|
      t.references :slashdot_posting
      t.references :url
    end

    add_index(:slashdot_postings_urls, [:slashdot_posting_id, :url_id])
  end

end
