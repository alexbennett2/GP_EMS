require 'capistrano/ext/multistage'

set :stages, ["staging","production"]
set :default_stage, "staging"



set :application "blog"

set :scm. :git
set :repository, "git@account"
set :scm_passphrase, ""

set :user, "server-user-name"