class AddAdminLinkColToHardwareTypes < ActiveRecord::Migration
  def self.up
    add_column :hardware_types, :admin_url, :string
  end

  def self.down
    remove_column :hardware_types, :admin_url
  end
end
