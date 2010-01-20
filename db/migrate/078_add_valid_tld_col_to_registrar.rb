class AddValidTldColToRegistrar < ActiveRecord::Migration
  def self.up
    add_column :registrars, :valid_tlds, :string
  end

  def self.down
    remove_column :registrars, :valid_tlds
  end
end
