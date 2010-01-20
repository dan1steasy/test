class AddTitleColToEmailTemplates < ActiveRecord::Migration
  def self.up
    add_column :email_templates, :title, :string
  end

  def self.down
    remove_column :email_templates, :title
  end
end
