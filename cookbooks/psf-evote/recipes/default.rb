#
# Cookbook Name:: psf-evote
# Recipe:: default
#
# Copyright (C) 2013 Noah Kantrowitz
#

include_recipe 'git'
include_recipe 'python'
include_recipe 'gunicorn'
include_recipe 'supervisor'

group 'evote' do
  system true
end

user 'evote' do
  comment 'evote service'
  gid 'evote'
  system true
  shell '/bin/false'
  home '/srv/evote'
end

directory '/srv/evote' do
  owner 'evote'
  group 'evote'
end

git '/srv/evote/web2py' do
  repository 'https://github.com/web2py/web2py.git'
  reference 'R-2.5.1'
  user 'evote'
end

%w{welcome examples admin}.each do |app|
  directory "/srv/evote/web2py/applications/#{app}" do
    action :delete
    recursive true
  end
end

git '/srv/evote/web2py/applications/init' do
  repository 'https://github.com/mdipierro/evote.git'
  reference 'master'
  user 'evote'
end

dburi = if Chef::Config[:solo]
  'sqlite://storage.sqlite' # For local testing
else
  db = data_bag_item('secrets', 'postgres')['evote']
  "postgres://#{db['user']}:#{db['password']}@#{db['hostname']}/#{db['database']}"
end

template '/srv/evote/web2py/applications/init/models/0.py' do
  source '0.py.erb'
  owner 'evote'
  group 'evote'
  mode '644'
  variables node['psf-evote'].merge(:dburi => dburi)
end

python_pip 'rsa'

supervisor_service 'evote' do
  command 'gunicorn -b 0.0.0.0 -w 4 wsgihandler'
  autostart true
  user 'evote'
  directory '/srv/evote/web2py'
  subscribes :restart, 'template[/srv/evote/web2py/applications/init/models/0.py]'
end
