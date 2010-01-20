class AddHardwareTypeIdColToHardware < ActiveRecord::Migration
  def self.up
    add_column :hardware, :hardware_type_id, :integer, :null => false
  end

  def self.down
    remove_column :hardware, :hardware_type_id
  end
end
