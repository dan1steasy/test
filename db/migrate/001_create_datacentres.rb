class CreateDatacentres < ActiveRecord::Migration
  def self.up
    create_table :datacentres do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :cabinet_space, :integer
    end
  end

  def self.down
    drop_table :datacentres
  end
end
