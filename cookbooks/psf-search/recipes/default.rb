# Make sure Nginx is installed
include_recipe "nginx"

secrets = data_bag_item("secrets", "elasticsearch")

file "#{node['nginx']['dir']}/htpasswd" do
  content "#{secrets['username']}:{PLAIN}#{secrets['password']}"

  owner "root"
  group "www-data"
  mode "640"

  notifies :reload, resources(:service => 'nginx')
end

template "#{node['nginx']['dir']}/sites-available/elasticsearch.conf" do
  source "elasticsearch.conf.erb"

  owner "root"
  group "root"
  mode "644"

  notifies :reload, resources(:service => 'nginx')
end

nginx_site "elasticsearch.conf" do
  enable true
end

nginx_site "default" do
  enable false
end


# Setup the Firewall to disallow ElasticSearch not via Nginx from anything other
#   than other ES nodes.
firewall "ufw" do
  action :enable
end

firewall_rule "ssh" do
  port     22
  action   :allow
  notifies :enable, 'firewall[ufw]'
end

firewall_rule "elasticsearch-nginx" do
  port   8200
  action :allow
end

search(:node, "role:elasticsearch AND chef_environment:#{node.chef_environment}") do |n|
  if n.attribute?('cloud')
    address = n['cloud']['local_ipv4']
  else
    address = n['ipaddress']
  end

  firewall_rule "elasticsearch-http-#{address}" do
    port node["elasticsearch"]["http"]["port"]
    protocol   :tcp
    source address
    action :allow
  end

  firewall_rule "elasticsearch-tcp-#{address}" do
    port_range 9300..9400
    protocol   :tcp
    source address
    action :allow
  end
end
