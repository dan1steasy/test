class AddAssetTagToHardware < ActiveRecord::Migration
  def self.up
    add_column :hardware, :asset_tag, :string
  end

  def self.down
    remove_column :hardware, :asset_tag
  end
end
