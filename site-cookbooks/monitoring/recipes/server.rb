include_recipe 'runit'
include_recipe 'riemann::server'
include_recipe 'graphite'
include_recipe 'monitoring::client'

%w{ruby1.9.3 rubygems}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

gem_package 'riemann-tools' do
  action :install
  gem_binary "/usr/bin/gem1.9.3"
end

template '/etc/riemann/riemann.config' do
  source 'riemann.config.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, resources(:service => 'riemann')
end
