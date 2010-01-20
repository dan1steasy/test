class CreateLoginDetails < ActiveRecord::Migration
  def self.up
    create_table :login_details do |t|
      t.column :description, :string
      t.column :username, :text
      t.column :password, :text
    end
  end

  def self.down
    drop_table :login_details
  end
end
