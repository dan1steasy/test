class AddDeletedColToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :is_active
  end
end
