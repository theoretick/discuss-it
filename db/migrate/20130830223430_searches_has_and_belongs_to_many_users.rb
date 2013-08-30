class SearchesHasAndBelongsToManyUsers < ActiveRecord::Migration
  def change
    create_table :searches_users, :id => false do |t|
      t.references :search
      t.references :user
    end
  end
end
