class DroppingCompanyOfTypeColumn < ActiveRecord::Migration
  def self.up
    remove_column :companies, :of_type
  end

  def self.down
    add_column :companies, :of_type, :string
  end
end
