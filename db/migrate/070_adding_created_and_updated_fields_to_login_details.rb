class AddingCreatedAndUpdatedFieldsToLoginDetails < ActiveRecord::Migration
  def self.up
    add_column :login_details, :created_at, :date
    add_column :login_details, :updated_at, :date
    add_column :login_details, :created_by, :integer
    add_column :login_details, :updated_by, :integer
  end

  def self.down
    remove_column :login_details, :updated_by
    remove_column :login_details, :created_by
    remove_column :login_details, :updated_at
    remove_column :login_details, :created_at
  end
end
