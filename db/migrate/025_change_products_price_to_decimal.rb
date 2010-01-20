class ChangeProductsPriceToDecimal < ActiveRecord::Migration
  def self.up
    # Apparently, this doesn't work in Rails versions prior to 1.2:
    #change_column :products, :price, :decimal
  end

  def self.down
    #change_column :products, :price, :integer
  end
end
