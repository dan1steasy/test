class AddRequiresHostingColToProductTable < ActiveRecord::Migration
  def self.up
    add_column :products, :requires_hosting, :boolean
  end

  def self.down
    remove_column :products, :requires_hosting
  end
end
