class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.decimal :value, precision: 13, scale: 8
      t.string :block

      t.timestamps
    end
  end
end
