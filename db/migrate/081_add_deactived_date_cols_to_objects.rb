class AddDeactivedDateColsToObjects < ActiveRecord::Migration
  def self.up
    add_column :accounts, :deactivated_on, :date
    add_column :hardware, :deactivated_on, :date
    add_column :companies, :deactivated_on, :date
    add_column :contacts, :deactivated_on, :date
  end

  def self.down
    remove_column :contacts, :deactivated_on
    remove_column :companies, :deactivated_on
    remove_column :hardware, :deactivated_on
    remove_column :accounts, :deactivated_on
  end
end
