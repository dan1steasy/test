class CreateAccountsProducts < ActiveRecord::Migration
  def self.up
    create_table :accounts_products, :id => false do |t|
      t.column :account_id, :integer, :null => false
      t.column :product_id, :integer, :null => false
    end

    add_index :accounts_products, :account_id
    add_index :accounts_products, :product_id
  end

  def self.down
    drop_table :accounts_products
  end
end
