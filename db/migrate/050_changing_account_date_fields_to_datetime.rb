class ChangingAccountDateFieldsToDatetime < ActiveRecord::Migration
  def self.up
    rename_column :accounts, :created_on, :created_at
    change_column :accounts, :created_at, :datetime
    rename_column :accounts, :updated_on, :updated_at
    change_column :accounts, :updated_at, :datetime
  end

  def self.down
    change_column :accounts, :updated_at, :date
    rename_column :accounts, :updated_at, :updated_on
    change_column :accounts, :created_at, :date
    rename_column :accounts, :created_at, :created_on
  end
end
