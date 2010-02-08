# == Schema Information
# Schema version: 20100208131342
#
# Table name: notes
#
#  id             :integer(4)    not null, primary key
#  encrypted_note :binary        
#  created_at     :datetime      
#  created_by     :integer(4)    
#  updated_at     :datetime      
#  updated_by     :integer(4)    
#  type           :string(255)   
#  company_id     :integer(4)    
#  contact_id     :integer(4)    
#  account_id     :integer(4)    
#  is_financial   :boolean(1)    
#

class Note < ActiveRecord::Base

  attr_accessor :decrypted_note

  def initialize(key, attributes = nil)
    super(attributes)
    @key = key
  end

  def encrypt_note(key = @key)
    sql = "UPDATE notes
           SET encrypted_note =
           AES_ENCRYPT(#{quote_value(self.decrypted_note)}, #{quote_value(key)})
           WHERE id = #{self.id}"
    # Run this update manually
    self.connection.execute sql
  end

  def decrypt_note(key = @key)
    sql = ["SELECT AES_DECRYPT(encrypted_note, ?) AS note FROM notes WHERE id = ?", key, self.id]
    result = Note.find_by_sql sql
    result[0].note
  end

end

class CompanyNote < Note
  belongs_to :company, :class_name => 'Company', :foreign_key => :company_id
end

class ContactNote < Note
  belongs_to :contact, :class_name => 'Contact', :foreign_key => :contact_id
end

class AccountNote < Note
  belongs_to :account, :class_name => 'Account', :foreign_key => :account_id
end
