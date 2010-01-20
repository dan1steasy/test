class RemoveDefaultTitleFromContacts < ActiveRecord::Migration
  def self.up
    change_column :contacts, :title, :string, :null => true, :default => ''
  end

  def self.down
    change_column :contacts, :title, :string, :null => false, :default => 'Mr.'
  end
end
