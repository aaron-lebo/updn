class AddTipsCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :tips_count, :integer, default: 0
  end
end
