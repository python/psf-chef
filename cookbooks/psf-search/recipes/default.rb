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

firewall_rule "elasticsearch-internal" do
  protocol :tcp
  port_range 9200..9400
  source "192.168.3.0/24"
  action :allow
end
