class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.column :order_id, :integer
      t.column :product_id, :integer
      t.column :quantity, :float
      t.column :percent_discount, :float
      t.column :fixed_discount, :decimal
      t.column :description, :text
    end
  end

  def self.down
    drop_table :order_items
  end
end
