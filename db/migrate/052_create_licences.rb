class CreateLicences < ActiveRecord::Migration
  def self.up
    create_table :licences do |t|
      t.column :license_type_id, :integer
      t.column :instances, :integer, :default => 1
      t.column :expires_on, :date, :default => nil
      t.column :in_use, :boolean, :default => false
      t.column :value, :text
    end
  end

  def self.down
    drop_table :licences
  end
end
