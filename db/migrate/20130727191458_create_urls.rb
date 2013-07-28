class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.text :target_url

      t.timestamps
    end
  end
end
