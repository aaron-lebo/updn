class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :from, index: true
      t.references :to, index: true
      t.references :story, index: true
      t.references :comment, index: true
      t.references :vote, index: true
      t.decimal :amount, precision: 13, scale: 8 
      t.boolean :anonymous
      t.timestamps
    end
  end
end
