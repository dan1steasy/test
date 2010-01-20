class ChangeContactCreatedAtToDateType < ActiveRecord::Migration
  def self.up
    #change_column :contacts, :created_at, :date
  end

  def self.down
    #change_column :contacts, :created_at, :datetime
  end
end
