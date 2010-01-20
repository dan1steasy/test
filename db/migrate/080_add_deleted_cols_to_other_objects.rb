class AddDeletedColsToOtherObjects < ActiveRecord::Migration
  def self.up
    add_column :hardware, :is_active, :boolean, :default => true
    add_column :companies, :is_active, :boolean, :default => true
    add_column :contacts, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :contacts, :is_active
    remove_column :companies, :is_active
    remove_column :hardware, :is_active
  end
end
