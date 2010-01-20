class ChangeEncryptedNoteFieldsToBinary < ActiveRecord::Migration
  def self.up
    change_column :login_details, :encrypted_username, :binary
    change_column :login_details, :encrypted_password, :binary
  end

  def self.down
    change_column :login_details, :encrypted_password, :text
    change_column :login_details, :encrypted_username, :text
  end
end
