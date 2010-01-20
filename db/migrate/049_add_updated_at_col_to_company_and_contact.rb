class AddUpdatedAtColToCompanyAndContact < ActiveRecord::Migration
  def self.up
    add_column :companies, :updated_at, :date

    add_column :contacts, :updated_at, :date
  end

  def self.down
    remove_column :contacts, :updated_at
    remove_column :companies, :updated_at
  end
end
