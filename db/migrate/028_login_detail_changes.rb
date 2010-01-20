class LoginDetailChanges < ActiveRecord::Migration
  def self.up
    rename_column :login_details, :username, :encrypted_username
    rename_column :login_details, :password, :encrypted_password
    add_column    :login_details, :type, :string
  end

  def self.down
    remove_column :login_details, :type
    rename_column :login_details, :encrypted_password, :password
    rename_column :login_details, :encrypted_username, :username
  end
end
