class AddBitcoinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deposit, :string
    add_column :users, :withdrawal, :string
  end
end
