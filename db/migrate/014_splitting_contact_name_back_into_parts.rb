class SplittingContactNameBackIntoParts < ActiveRecord::Migration
  def self.up
    rename_column :contacts, :name, :forename
    add_column    :contacts, :surname, :string
  end

  def self.down
    remove_column :contacts, :surname
    rename_column :contacts, :forename, :name
  end
end
