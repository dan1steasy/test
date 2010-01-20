# == Schema Information
# Schema version: 20100120120153
#
# Table name: email_templates
#
#  id            :integer(4)    not null, primary key
#  subject       :string(255)   
#  html_body     :text          
#  template_name :string(255)   
#  text_body     :text          
#

class EmailTemplate < ActiveRecord::Base
  validates_presence_of :template_name
end
