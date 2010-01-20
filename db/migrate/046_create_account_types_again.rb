class CreateAccountTypesAgain < ActiveRecord::Migration
  def self.up
    create_table :account_types do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :product_id, :integer
      t.column :requires_hardware, :boolean
      t.column :requires_hosting, :boolean
    end
  end

  def self.down
    drop_table :account_types
  end
end
