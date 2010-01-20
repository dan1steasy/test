class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.text :description
      t.boolean :is_complete
      t.integer :created_by
      t.integer :updated_by
      t.integer :completed_by

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
