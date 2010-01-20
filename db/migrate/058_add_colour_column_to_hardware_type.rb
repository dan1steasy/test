class AddColourColumnToHardwareType < ActiveRecord::Migration
  def self.up
    add_column :hardware_types, :colour, :string
  end

  def self.down
    remove_column :hardware_types, :colour
  end
end
