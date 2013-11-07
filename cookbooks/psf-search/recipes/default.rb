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
