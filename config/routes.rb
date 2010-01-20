ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.account "accounts/:fqdn",
              :controller => 'accounts', :action => 'show_fqdn',
              :requirements => {:fqdn => /([\w-]+\.){1,4}[\w]+/}

  map.hardware "hardware/:name",
              :controller => 'hardware', :action => 'show_name',
              :requirements => {:name => /([\w-]+\.){1,4}[\w]+/}

  map.resources :tasks
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => 'main'

  # Special routing for registrar-based URLs to domainreg controller.
  map.connect 'domainreg/registrars/:r_action/:id',
              :controller => 'domainreg',
              :action => 'registrars'

  # Special routing for ip_addresses/list, to allow IP addresses through
  map.connect 'ip_addresses/list/:ip',
              :controller => 'ip_addresses', :action => 'list',
              :requirements => {:ip => /.+/}

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
