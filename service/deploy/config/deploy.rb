set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :use_sudo, false

set :application, "social-maps-service"
set :user, "root"
set :group, "root"

set :scm, :git
set :branch, "develop"
set :repository,  "git@github.com:genweb2/social-maps-service.git"

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

task :uname do
  run "uname -a"
end