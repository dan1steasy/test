class AddNewFieldsToHardware < ActiveRecord::Migration
  def self.up
    add_column :hardware, :created_at, :datetime
    add_column :hardware, :updated_at, :datetime

    add_column :hardware, :created_by, :integer
    add_column :hardware, :updated_by, :integer
  end

  def self.down
    remove_column :hardware, :updated_by
    remove_column :hardware, :created_by
    
    remove_column :hardware, :updated_at
    remove_column :hardware, :created_at
  end
end
