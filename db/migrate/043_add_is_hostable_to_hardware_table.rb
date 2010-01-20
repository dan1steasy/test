class AddIsHostableToHardwareTable < ActiveRecord::Migration
  def self.up
    add_column :hardware, :is_hostable, :boolean
  end

  def self.down
    remove_column :hardware, :is_hostable
  end
end
