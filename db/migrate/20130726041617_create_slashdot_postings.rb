class CreateSlashdotPostings < ActiveRecord::Migration
  def change
    create_table :slashdot_postings do |t|
      t.string :title
      t.string :permalink
      t.text :urls

      t.timestamps
    end
  end
end
