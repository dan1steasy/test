class RenamingTypeColumnToOfType < ActiveRecord::Migration
  def self.up
    rename_column :companies, :type, :of_type
  end

  def self.down
    rename_column :companies, :of_type, :type
  end
end
