class AddUserAndPassFieldsToRegistrar < ActiveRecord::Migration
  def self.up
    add_column :registrars, :encrypted_username, :binary
    add_column :registrars, :encrypted_password, :binary
  end

  def self.down
    remove_column :registrars, :encrypted_username
    remove_column :registrars, :encrypted_password
  end
end
