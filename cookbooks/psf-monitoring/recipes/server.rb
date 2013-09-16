api_keys = data_bag_item("api", "pagerduty")

chef_gem 'chef-rewind'
require 'chef/rewind'

include_recipe 'runit'
include_recipe 'riemann::server'
include_recipe 'graphite'
include_recipe 'firewall'
include_recipe 'psf-monitoring::client'

%w{ruby1.9.3 rubygems}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

gem_package 'riemann-tools' do
  action :install
  gem_binary '/usr/bin/gem1.9.3'
end

template '/etc/riemann/riemann.config' do
  source 'riemann.config.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[riemann]'
  variables({
    'pagerduty' => api_keys['pagerduty']
  })
end

firewall 'ufw' do
  action :enable
end

firewall_rule 'ssh' do
  port 22
  protocol :tcp
  action :allow
end

firewall_rule 'http' do
  port 80
  protocol :tcp
  action :allow
end

firewall_rule 'riemann_our_net' do
  port 5555
  source '140.211.10.64/26'
  direction :in
  action :allow
end

firewall_rule 'graphite_our_net' do
  port 2003
  source '140.211.10.64/26'
  direction :in
  action :allow
end

firewall_rule 'riemann_speed' do
  port 5555
  source '140.211.15.123/32'
  direction :in
  action :allow
end

firewall_rule 'graphite_speed' do
  port 2003
  source '140.211.15.123/32'
  direction :in
  action :allow
end

storage_template = "#{node['graphite']['base_dir']}/conf/storage-schemas.conf"

rewind :template => storage_template do
  source 'storage-schemas.conf.erb'
  cookbook_name 'psf-monitoring'
end
