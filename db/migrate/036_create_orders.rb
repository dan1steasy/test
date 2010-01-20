class CreateOrders < ActiveRecord::Migration
  def self.up
    # Make the auto_increment value start at 400 to avoid reusing order IDs from the old system.
    create_table :orders, :options => "auto_increment = 4000" do |t|
      t.column :created_at, :timestamp
      t.column :user_id, :integer
      t.column :company_id, :integer
      t.column :contact_id, :integer
      t.column :is_complete, :boolean
    end
  end

  def self.down
    drop_table :orders
  end
end
