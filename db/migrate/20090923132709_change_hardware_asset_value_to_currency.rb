class ChangeHardwareAssetValueToCurrency < ActiveRecord::Migration
  def self.up
    change_column :hardware, :asset_value, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    change_column :hardware, :asset_value, :decimal
  end
end
