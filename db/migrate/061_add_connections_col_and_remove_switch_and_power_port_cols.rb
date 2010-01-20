class AddConnectionsColAndRemoveSwitchAndPowerPortCols < ActiveRecord::Migration
  def self.up
    remove_column :hardware, :power_port_id
    remove_column :hardware, :switch_port_id

    # The connections string will be used to store our switch and apc unit connections
    add_column :hardware, :connections, :string
  end

  def self.down
    remove_column :hardware, :connections

    add_column :hardware, :switch_port_id
    add_column :hardware, :power_port_id
  end
end
