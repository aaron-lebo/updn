class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user, index: true
      t.string :txid
      t.boolean :deposit
      t.string :to
      t.decimal :amount, precision: 13, scale: 8
      t.integer :confirmations
      t.datetime :time
      
      t.timestamps
    end
  end
end
