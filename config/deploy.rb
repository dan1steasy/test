set :application, "ae5"
set :scm, :git
set :repository,  "git@ae.1steasy.net:ae5.git"
set :branch, "master"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

ssh_options[:forward_agent] = true
set :user, 'root'
set :use_sudo, false
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

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
  run "chmod g+w #{release_path}/tmp"
end

desc "Symlink the DB config file from shared directory to current"
task :symlink_database_yml do
  run "ln -nsf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

namespace :phpmyadmin do
  desc "Disable access to phpMyAdmin"
  task :disable, :roles => :web do
    run "echo 'deny from all' > #{current_path}/public/phpmyadmin/.htaccess"
  end

  desc "Enable access to phpMyAdmin"
  task :enable, :roles => :web do
    run "rm -f #{current_path}/public/phpmyadmin/.htaccess"
  end
end

after 'deploy:update_code', 'symlink_database_yml', 'chgrp'
