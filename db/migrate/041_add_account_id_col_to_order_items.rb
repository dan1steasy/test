class AddAccountIdColToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :account_id, :integer
  end

  def self.down
    remove_column :order_items, :account_id
  end
end
