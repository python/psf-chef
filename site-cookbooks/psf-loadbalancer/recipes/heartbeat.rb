
include_recipe "heartbeat"

secrets = data_bag_item('secrets', 'heartbeat')
lb_nodes = search(:node, "recipes:#{cookbook_name}\\:\\:#{recipe_name}")
# Make sure we always have ourselves
lb_nodes << node if lb_nodes.select{|n| n['fqdn'] == node['fqdn']}.empty?

template "/etc/ha.d/ha.cf" do
  source "ha.cf.erb"
  mode "644"
  owner "root"
  group "root"
  notifies :restart, "service[heartbeat]"
  variables :nodes => lb_nodes, :interface => node['network']['default_interface']
end

template "/etc/ha.d/authkeys" do
  source "authkeys.erb"
  owner "root"
  group "root"
  mode "600"
  notifies :restart, "service[heartbeat]"
  variables secrets.raw_data
end

template "/etc/ha.d/haresources" do
  source "haresources.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, "service[heartbeat]"
  variables :primary => lb_nodes.sort_by{|n| n['fqdn']}.first
end
