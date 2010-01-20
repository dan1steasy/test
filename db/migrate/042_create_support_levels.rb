class CreateSupportLevels < ActiveRecord::Migration
  def self.up
    create_table :support_levels do |t|
      t.column :code, :string
      t.column :name, :string
      t.column :description, :text
    end
  end

  def self.down
    drop_table :support_levels
  end
end
