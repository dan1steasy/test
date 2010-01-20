class AccountModelChanges < ActiveRecord::Migration
  def self.up
    drop_table :account_types

    # We want to get rid of dom_reg_id & acc_type_id
    remove_column :accounts, :domain_registration_id
    remove_column :accounts, :account_type_id

    # We want to add product_id and updated_on
    add_column :accounts, :product_id, :integer
    add_column :accounts, :updated_on, :date
  end

  def self.down
    remove_column :accounts, :updated_on
    remove_column :accounts, :product_id
    add_column :accounts, :account_type_id, :integer
    add_column :accounts, :domain_registration_id, :integer

    create_table :account_types do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :product_id, :integer
    end
  end
end
