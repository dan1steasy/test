class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column :name, :string, :null => false
      t.column :address1, :string, :null => false
      t.column :address2, :string
      t.column :town, :string
      t.column :county, :string
      t.column :country, :string
      t.column :postcode, :string, :null => false
      t.column :phone1, :string
      t.column :phone2, :string
      t.column :fax, :string
      t.column :url, :string
      t.column :vat_code, :string
      t.column :created_at, :date, :null => false
    end
  end

  def self.down
    drop_table :companies
  end
end
