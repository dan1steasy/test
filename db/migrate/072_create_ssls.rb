class CreateSsls < ActiveRecord::Migration
  def self.up
    create_table :ssls do |t|
      t.column :account_id, :integer, :null => false
      t.column :key, :text
      t.column :request, :text
      t.column :certificate, :text
      t.column :expires_on, :date
    end
  end

  def self.down
    drop_table :ssls
  end
end
