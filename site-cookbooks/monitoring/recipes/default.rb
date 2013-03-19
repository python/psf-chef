include_recipe 'runit'
include_recipe 'riemann::server'
include_recipe 'riemann::health'

include_recipe 'apt'
include_recipe 'graphite'

template '/etc/riemann/riemann.config' do
  source 'riemann.config.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, resources(:service => 'riemann')
end

apt_repository "collectd" do
  uri "http://ppa.launchpad.net/vbulax/collectd5/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "013B9839"
end
