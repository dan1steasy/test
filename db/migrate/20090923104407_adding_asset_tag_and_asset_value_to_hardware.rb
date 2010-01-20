class AddingAssetTagAndAssetValueToHardware < ActiveRecord::Migration
  # Asset_tag is not actually added in this migration.
  def self.up
    add_column :hardware, :asset_value, :decimal
  end

  def self.down
    remove_column :hardware, :asset_value
  end
end
