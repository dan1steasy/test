module ContactsHelper

  def company_multiple_select(companies, selected_ids=nil)
    html = '<select id="company_ids" name="company_ids[]" size="5" multiple>' + "\n"
    companies.each do |company|
      if(!selected_ids.nil?) and (selected_ids.include?(company.id))
        selected = ' selected="selected"'
      else
        selected = ''
      end
      html += "\t<option value=\"#{company.id}\"#{selected}>#{company.name}</option>\n"
    end
    html
  end

end
