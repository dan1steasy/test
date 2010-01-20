class AddHasApiFieldToRegistrar < ActiveRecord::Migration
  def self.up
    add_column :registrars, :has_api, :boolean
  end

  def self.down
    remove_column :registrars, :has_api
  end
end
