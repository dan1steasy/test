module EmailsHelper

  def contact_emails(contact_array, type)
    # Method to display the contact email addresses
    # for an array of contacts
    img_id = "hw_contacts_#{type}_img"
    div_id = "hw_contacts_#{type}_div"
    html = image_tag('more.gif', :title => "Show/hide addresses",
                     :onclick => "Effect.toggle('#{div_id}', 'slide');
                                  imgSwap('#{img_id}');")
    html += '<div id="' + div_id + '" style="display: none;"><p>'
    contact_array[type].each do |contact|
      if contact.is_subscribed
        html += contact.email + ', '
      else
        html += '<span class="error">' + contact.email + '</span>, '
      end
    end
    html = html.reverse.gsub(/^ ,/, '').reverse # remove the last comma and space
    html += '</p></div>'
  end

  def hosted_contact_emails(contact_array, type)
    # Method to display the contact email addresses per server
    img_id = "hosted_contacts_#{type}_img"
    div_id = "hosted_contacts_#{type}_div"
    html = image_tag('more.gif', :title => "Show/hide addresses",
                     :onclick => "Effect.toggle('#{div_id}', 'slide');
                                  imgSwap('#{img_id}');")
    html += '<div id="' + div_id + '" style="display: none;"><p>'
    contact_array[type].each do |server_array|
      html += "<strong>#{server_array[0]}:</strong><br />"
      contacts = server_array[1]
      if server_array[1].blank?
        html += "<em>No hosted #{type.to_s} contacts on this hardware.</em><br />"
      else
        contacts.each do |contact|
          if contact.is_subscribed
            html += contact.email + ', '
          else
            html += '<span class="error">' + contact.email + '</span>, '
          end
        end
        html = html.reverse.gsub(/^ ,/, '').reverse # remove the last comma and space
        html += '<br />'
      end
    end
    html += '</p></div>'
  end
end
