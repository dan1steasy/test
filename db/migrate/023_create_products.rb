class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :code, :string
      t.column :name, :string
      t.column :description, :string
      t.column :category_id, :integer
      # :decimal options don't work in rails < 1.2
      t.column :price, :decimal, {:precision=>8, :scale=>2, :default=>0}
      t.column :created_on, :date
    end
  end

  def self.down
    drop_table :products
  end
end
