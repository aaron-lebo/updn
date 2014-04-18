class AddTipsCountToStories < ActiveRecord::Migration
  def change
    add_column :stories, :tips_count, :integer, default: 0
  end
end
