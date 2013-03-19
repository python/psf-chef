include_recipe 'runit'
include_recipe 'riemann::server'
include_recipe 'graphite'

template '/etc/riemann/riemann.config' do
  source 'riemann.config.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, resources(:service => 'riemann')
end
