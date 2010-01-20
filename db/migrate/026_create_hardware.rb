class CreateHardware < ActiveRecord::Migration
  def self.up
    create_table :hardware do |t|
      t.column :company_id, :integer, :null => false
      t.column :cabinet_id, :integer
      t.column :name, :string
      t.column :description, :text
      t.column :starting_cabinet_bay, :integer
      t.column :u_size, :integer, :default => 1
      t.column :power_port_id, :integer
      t.column :switch_port_id, :integer
      t.column :mac_address, :string
      t.column :model_number, :string
      t.column :serial_number, :string
    end
  end

  def self.down
    drop_table :hardware
  end
end
