# Get our Database settings
database = data_bag_item("secrets", "postgres")

# Get our secrets
secrets = data_bag_item("secrets", "pypi")

elasticsearch = data_bag_item("secrets", "elasticsearch")

# Make sure Nginx is installed
include_recipe "nginx"

# Make sure supervisor is available to us
include_recipe "supervisor"

environ = {
  "LANG" => "en_US.UTF8",
  "WAREHOUSE_CONF" => "/opt/warehouse/etc/config.yml",
  "SENTRY_DSN" => secrets["sentry"]["dsn"],
}

apt_repository "pypy" do
    uri "http://ppa.launchpad.net/pypy/ppa/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "2862D0785AFACD8C65B23DB0251104D968854915"
end

apt_repository "warehouse" do
    uri "http://162.209.104.234/"
    distribution node['lsb']['codename']
    components ["main"]
    arch "amd64"
    key "warehouse.gpg"
end

execute "update repositories" do
  command "apt-get update -q -y"
end

package "warehouse" do
  action :upgrade

  notifies :restart, "supervisor_service[warehouse]"
end

gunicorn_config "/opt/warehouse/etc/gunicorn.config.py" do
  owner "root"
  group "warehouse"

  listen "unix:/opt/warehouse/var/run/warehouse.sock"

  action :create
  notifies :restart, "supervisor_service[warehouse]"
end

eshosts = []
if node["warehouse"]["elasticsearch"]["hosts"].empty?
  search(:node, "role:elasticsearch AND chef_environment:#{node.chef_environment}") do |n|
    eshosts << {"host" => n['fqdn'], "port" => 8200}
  end
else
  eshosts = node["warehouse"]["elasticsearch"]["hosts"]
end

file "/opt/warehouse/etc/config.yml" do
  owner "root"
  group "warehouse"
  mode "0640"
  backup false

  content ({
    "debug" => false,
    "site" => {
      "name" => "Python Package Index (Preview)",
    },
    "database" => {
      "url" => database["pypi"]["url"],
    },
    "redis" => {
      "url" => "redis://localhost:6379/0",
    },
    "search" => {
      "hosts" => eshosts,
      "client_options" => {
        "http_auth" => "#{elasticsearch['username']}:#{elasticsearch['password']}",
        "use_ssl" => true,
      },
    },
    "assets" => {
      "directory" => "/opt/warehouse/var/www/static"
    },
    "urls" => {
      "documentation" => "http://pythonhosted.org/",
    },
    "paths" => {
      "packages" => "/data/packages",
      "documentation" => "/data/packagedocs",
    },
    "cache" => {
      "browser" => {
        "index" => 900,
        "simple" => 900,
        "packages" => 900,
        "project_detail" => 900,
        "user_profile" => 900,
      },
      "varnish" => {
        "index" => 60,
        "simple" => 86400,
        "packages" => 86400,
        "project_detail" => 60,
        "user_profile" => 60,
      },
    },
    "security" => {
      "csp" => {
        "default-src" => ["https://" + node["warehouse"]["domains"].first],
      },
    },
    "sentry" => {
      "dsn" => secrets["sentry"]["dsn"],
    }
  }.to_yaml)

  notifies :restart, "supervisor_service[warehouse]"
end

python_pip "gunicorn" do
  virtualenv "/opt/warehouse"
  action :upgrade
  notifies :restart, "supervisor_service[warehouse]"
end

supervisor_service "warehouse" do
  command "/opt/warehouse/bin/gunicorn -c /opt/warehouse/etc/gunicorn.config.py warehouse.wsgi"
  process_name "warehouse"
  directory "/opt/warehouse"
  environment environ
  user "warehouse"
  action :enable
end

template "#{node['nginx']['dir']}/sites-available/warehouse.conf" do
  owner "root"
  group "root"
  mode "0640"
  backup false

  source "nginx-warehouse.conf.erb"

  variables ({
    :domains => node["warehouse"]["domains"],
    :sock => "/opt/warehouse/var/run/warehouse.sock",
    :name => "warehouse",
    :static_root => "/opt/warehouse/var/www",
  })

  notifies :reload, "service[nginx]"
end

nginx_site "warehouse.conf" do
  enable true
end
