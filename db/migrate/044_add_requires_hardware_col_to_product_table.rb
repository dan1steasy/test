class AddRequiresHardwareColToProductTable < ActiveRecord::Migration
  def self.up
    add_column :products, :requires_hardware, :boolean
  end

  def self.down
    remove_column :products, :requires_hardware
  end
end
