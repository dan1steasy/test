class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :encrypted_note, :binary
      t.column :created_at,     :datetime
      t.column :created_by,     :integer
      t.column :updated_at,     :datetime
      t.column :updated_by,     :integer
      t.column :type,           :string
    end
  end

  def self.down
    drop_table :notes
  end
end
