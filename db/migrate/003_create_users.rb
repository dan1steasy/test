class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string
      t.column :real_name, :string
      t.column :email, :string
      t.column :password, :string
      t.column :pin, :string
      t.column :key, :binary # master key encoded with PIN
    end
  end

  def self.down
    drop_table :users
  end
end
