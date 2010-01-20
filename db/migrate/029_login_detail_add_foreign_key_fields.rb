class LoginDetailAddForeignKeyFields < ActiveRecord::Migration
  def self.up
    add_column :login_details, :account_id, :integer
    add_column :login_details, :company_id, :integer
    add_column :login_details, :contact_id, :integer
    add_column :login_details, :registrar_id, :integer
  end

  def self.down
    remove_column :login_details, :registrar_id
    remove_column :login_details, :contact_id
    remove_column :login_details, :company_id
    remove_column :login_details, :account_id
  end
end
