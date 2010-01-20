set :application, "ae5"
set :repository,  "svn+ssh://tim@ecrm.1steasy.net/home/repos/ae5"
set :deploy_via, :export

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

ssh_options[:forward_agent] = true
set :user, 'root'
set :use_sudo, false
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

role :app, "ae.1steasy.net"
role :web, "ae.1steasy.net"
role :db,  "ae.1steasy.net", :primary => true

namespace :deploy do
  task :start, :roles => :app do
  end

  task :stop, :roles => :app do
  end

  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

desc "Change group owenerships to allow caching"
task :chgrp do
  # Allow our javascripts to be cached
  run "chgrp nobody #{release_path}/public/javascripts"
  # Allow our whois queries to be cached
  run "chgrp nobody #{release_path}/tmp"
end

after 'deploy:update_code', 'chgrp'
