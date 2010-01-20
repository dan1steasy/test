# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Helper method to return the currently logged-in user's decrypted key
  def decryption_key
    user = User.find session[:user]
    user.decrypt_key
  end

  # Helper method to assemble top navigation items in views
  def topnav_items(info={:object_id => 0, :object_name => nil})
    # Set up hashes of links
    if info[:object_name].blank?
      name = controller.controller_name.gsub('_', ' ')
    else
      name = info[:object_name].pluralize
    end
    index_link = {:name => name.capitalize + " index",
                 :target => {:controller => controller.controller_name}}
    list_link  = {:name => "List " + name,
                 :target => {:controller => controller.controller_name, :action => 'list'}}
    new_link   = {:name => "Add new " + ActiveSupport::Inflector.singularize(name),
                 :target => {:controller => controller.controller_name, :action => 'new'}}
    edit_link  = {:name => "Edit " + ActiveSupport::Inflector.singularize(name),
                 :target => {:controller => controller.controller_name, :action => 'edit',
                 :id => info[:object_id]}}
    show_link  = {:name => "View " + ActiveSupport::Inflector.singularize(name),
                 :target => {:controller => controller.controller_name, :action => 'show',
                 :id => info[:object_id]}}
    main_link  = {:name => "Main", :target => {:controller => 'main'}}
    cp_link    = {:name => "Control Panel", :target => {:controller => 'cp'}}
    # Create an array to hold the links in order
    link_array = []
    case params[:action]
    when "index", ""
      link_array[0] = list_link
      link_array[1] = new_link
    when "list", "list_deactivated"
      link_array[0] = index_link
      link_array[1] = new_link
    when "new", "create"
      link_array[0] = index_link
      link_array[1] = list_link
    when "show"
      link_array[0] = edit_link
      link_array[1] = index_link
      link_array[2] = list_link
    when "edit"
      link_array[0] = show_link
      link_array[1] = index_link
      link_array[2] = list_link
    when "search"
      link_array[0] = index_link
      link_array[1] = new_link
    end
    # Adding a special case for :fqdn
    if params[:fqdn]
      link_array[0] = edit_link
      link_array[1] = index_link
      link_array[2] = list_link
    end
    link_array << main_link << cp_link
    html = ''
    link_array.each do |link|
      html += "<li>" + link_to(link[:name], link[:target]) + "</li>"
    end
    return html
  end

  # Helper method to print out a table of characters, each one being a link
  # to a :controller/list/x URL
  def starting_character_table
    html = "<table>\n<tr>"
    ('A'..'Z').each do |char|
      html += "<td><a href=\"/#{controller.controller_name}/list/#{char.downcase}\">#{char}</a></td>"
    end
    html += "</tr>\n<tr>"
    (0..9).each do |digit|
      html += "<td><a href=\"/#{controller.controller_name}/list/#{digit}\">#{digit}</a></td>"
    end
    html += "</tr>\n</table>"
    return html
  end

  # Taken from Rails Recipes, p13
  def in_place_select_editor_field(object, method, tag_options={}, in_place_editor_options={})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag   => "span",
                   :id    => "#{object}_#{method}_#{tag.object.id}_in_place_editor",
                   :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = 
      in_place_editor_options[:url] ||
      url_for({:action => "set_#{object}_#{method}", :id => tag.object.id})
    tag.to_content_tag(tag_options.delete(:tag), tag_options) +
      in_place_select_editor(tag_options[:id], in_place_editor_options)
  end

  # Taken from Rails Recipes, p14
  def in_place_select_editor(field_id, options={})
    function =  "new Ajax.InPlaceSelectEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"
    function << (', ' + options_for_javascript({'selectOptionsHTML' => %('#{escape_javascript(options[:select_options].gsub(/\n/, ""))}')})) if options[:select_options]
    function << ')'
    javascript_tag(function)
  end

  # Method to display the icons for edit & delete
  # options, common among all 'show' actions
  def edit_and_delete_options(object, confirmation_msg=nil)
    if confirmation_msg == nil
      confirmation_msg = "Are you sure you want to delete this #{object.class.to_s.underscore.humanize.downcase}?"
    end
    html  = "<div class=\"options\">\n"
    html += link_to(image_tag('edit.gif', :title => "Edit #{object.class.to_s.underscore.humanize.downcase}"),
                   {:action => 'edit', :id => object})
    if object.respond_to? :is_active
      if object.is_active
        title = "Deactivate #{object.class.to_s.underscore.humanize.downcase}"
      else
        title = "Delete #{object.class.to_s.underscore.humanize.downcase}"
      end
    else
      title = "Delete #{object.class.to_s.underscore.humanize.downcase}"
    end
      html += link_to(image_tag('delete.gif', :title => title), 
                     {:action => 'destroy', :id => object },
                     :confirm => confirmation_msg, :method => "post")
    html += "\n</div>"
    return html
  end

  # Method to show the audit for an object (currently
  # used by Company, Contact, Hardware & Account models.
  def audit_div(object)
    if object.respond_to? "created_at"
      created = object.created_at.to_s(:long)
    elsif object.respond_to? "created_on"
      created = object.created_on.to_s(:long)
    else
      created = "Unknown"
    end

    if object.respond_to? "updated_at"
      updated = object.updated_at.to_s(:long)
    elsif object.respond_to? "updated_on"
      updated = object.updated_on.to_s(:long)
    else
      updated = "Unknown"
    end

    html = "<div class=\"audit\">\n<p>Created #{created} by #{User.find(object.created_by).real_name}</p>\n"
    if object.updated_by != nil
      html += "<p>Last updated #{updated} by #{User.find(object.updated_by).real_name}</p>"
    end
    html += "</div>"
    return html
  end

  def focus_first_field(form_name=nil, just_code=false)
    if form_name == nil then form_name = ActiveSupport::Inflector.singularize(controller.controller_name) end
    if just_code
      "Form.focusFirstElement('#{form_name}')"
    else
      " onload=\"Form.focusFirstElement('#{form_name}')\""
    end
  end

  # Method to provide a hovering-div help message.
  def help_message(message)
    '<a href="#" class="info"><img src="/images/help.gif" /><span>' + message + '</span></a>'
  end

  def ip_address_multiple_select(available_ips_for_select)
    html = ''
    available_ips_for_select.each do |ip_collection|
      html += "<optgroup label=\"#{ip_collection.type_name}\">\n"
        ip_collection.options.each do |ip_addr|
          if ip_collection.type_name == "Current IP allocations"
            selected = ' selected="selected"' 
          else
            selected = ''
          end
          html += "\t<option value=\"#{ip_addr.id.to_s}\"#{selected}>#{ip_addr.address}</option>\n"
        end
      html += "</optgroup>\n"
    end
    html
  end

end
