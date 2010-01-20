class CreateCabinets < ActiveRecord::Migration
  def self.up
    create_table :cabinets do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :datacentre_id, :integer
      t.column :u_space, :integer
    end
  end

  def self.down
    drop_table :cabinets
  end
end
