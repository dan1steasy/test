class ChangeContactNameToSingleField < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :middle_names
    remove_column :contacts, :surname
    rename_column :contacts, :forename, :name
  end

  def self.down
    rename_column :contacts, :name, :forename
    add_column    :contacts, :surname, :string
    add_column    :contacts, :middle_names, :string
  end
end
