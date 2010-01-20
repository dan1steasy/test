class AddCreatedByAndUpdatedByColumns < ActiveRecord::Migration
  def self.up
    add_column :companies, :created_by, :integer
    add_column :companies, :updated_by, :integer
    
    add_column :contacts, :created_by, :integer
    add_column :contacts, :updated_by, :integer

    add_column :accounts, :created_by, :integer
    add_column :accounts, :updated_by, :integer
  end

  def self.down
    remove_column :companies, :created_by
    remove_column :companies, :updated_by

    remove_column :contacts, :created_by
    remove_column :contacts, :updated_by

    remove_column :accounts, :created_by
    remove_column :accounts, :updated_by
  end
end
