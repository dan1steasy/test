class CreateKeyTestTable < ActiveRecord::Migration
  def self.up
    create_table :key_tests do |t|
      t.column :encrypted_phrase, :binary
    end
  end

  def self.down
    drop_table :key_tests
  end
end
