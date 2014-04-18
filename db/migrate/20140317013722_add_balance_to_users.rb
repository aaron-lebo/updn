class AddBalanceToUsers < ActiveRecord::Migration
  def change
    self.add_column :users, :balance, :decimal, precision: 13, scale: 8, 
      default: 0.0
  end
end
