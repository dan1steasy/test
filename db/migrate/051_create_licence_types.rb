class CreateLicenceTypes < ActiveRecord::Migration
  def self.up
    create_table :licence_types do |t|
      t.column :name, :string
      t.column :description, :text
    end
  end

  def self.down
    drop_table :licence_types
  end
end
