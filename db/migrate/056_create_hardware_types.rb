class CreateHardwareTypes < ActiveRecord::Migration
  def self.up
    create_table :hardware_types do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :hardware_types
  end
end
