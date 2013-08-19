class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.text :query_url
      t.references :user, index: true

      t.timestamps
    end
  end
end
