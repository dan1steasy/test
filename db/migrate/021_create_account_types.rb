class CreateAccountTypes < ActiveRecord::Migration
  def self.up
    create_table :account_types do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :product_id, :integer
    end
  end

  def self.down
    drop_table :account_types
  end
end
