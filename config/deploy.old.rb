require 'mongrel_cluster/recipes'
set :application, "ae5"
set :repository,  "svn+ssh://tim@ecrm.1steasy.net/home/repos/ae5"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
#set :scm, :subversion
#set :scm_command, "/usr/bin/svn"
#set :local_scm_command, "/usr/bin/svn" 

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

role :app, "ae.1steasy.net"
role :web, "ae.1steasy.net"
role :db,  "ae.1steasy.net", :primary => true
