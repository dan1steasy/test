class RemoveProductIdColFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :product_id
  end

  def self.down
    add_column :accounts, :product_id, :integer
  end
end
