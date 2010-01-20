class ChangesToEmailTemplates < ActiveRecord::Migration
  def self.up
    rename_column :email_templates, :body, :html_body
    add_column :email_templates, :text_body, :text
  end

  def self.down
    remove_column :email_templates, :text_body
    rename_column :email_templates, :html_body, :body
  end
end
