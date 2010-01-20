class RemovingInstancesColAndAddingCreatedOnToLicences < ActiveRecord::Migration
  def self.up
    remove_column :licences, :instances
    add_column    :licences, :created_on, :date
  end

  def self.down
    remove_column :licences, :created_on
    add_column    :licences, :instances, :integer
  end
end
