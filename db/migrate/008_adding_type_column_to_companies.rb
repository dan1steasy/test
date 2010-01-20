class AddingTypeColumnToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :type, :string
  end

  def self.down
    remove_column :companies, :type
  end
end
