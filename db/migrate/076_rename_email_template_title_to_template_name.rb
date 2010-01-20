class RenameEmailTemplateTitleToTemplateName < ActiveRecord::Migration
  def self.up
    rename_column :email_templates, :title, :template_name
  end

  def self.down
    rename_column :email_templates, :template_name, :title
  end
end
