class AddingDefaultFalseToTasksIsComplete < ActiveRecord::Migration
  def self.up
    change_column :tasks, :is_complete, :boolean, :default => false
  end

  def self.down
    change_column :tasks, :is_complete, :boolean
  end
end
