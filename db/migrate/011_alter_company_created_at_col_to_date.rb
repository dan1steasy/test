class AlterCompanyCreatedAtColToDate < ActiveRecord::Migration
  def self.up
    # This won't work. Needs to be done manually.
    #change_column :companies, :created_at, :date, :default => "2000-01-01"
  end

  def self.down
    #change_column :companies, :created_at, :datetime
  end
end
