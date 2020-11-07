class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.string :name
      t.float :percent_off
      t.integer :min_amount
      t.references :merchant, foreign_key: true

      t.timestamps
    end
  end
end
