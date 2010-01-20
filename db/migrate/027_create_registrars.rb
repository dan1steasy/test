class CreateRegistrars < ActiveRecord::Migration
  def self.up
    create_table :registrars do |t|
      t.column :name, :string
      t.column :url, :string
    end
  end

  def self.down
    drop_table :registrars
  end
end
