class AddAuthorAndCommentCountToSlashdotPostings < ActiveRecord::Migration
  def change
    add_column :slashdot_postings, :author, :string
    add_column :slashdot_postings, :comment_count, :integer
  end
end
