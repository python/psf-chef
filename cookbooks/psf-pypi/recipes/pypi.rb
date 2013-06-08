database = data_bag_item("secrets", "postgres")["pypi"]
secrets = data_bag_item("secrets", "pypi")

include_recipe "postgresql::client"
include_recipe "python"
include_recipe "mercurial"
include_recipe "apache2"
include_recipe "apache2::mod_wsgi"

package "libssl-dev" do end
package "swig" do end
package "python-m2crypto" do end

user node["pypi"]["user"] do
  comment "Python Package Index"
  home "/srv/pypi/"
  system true
end

directory "/srv/pypi" do
  mode "755"
  user "root"
  group node["pypi"]["group"]
end

# python_virtualenv "/srv/pypi/env" do
#   group "www-data"
#   options "--system-site-packages"
#   action :create
# end

execute "install requirements" do
  command "pip install -r requirements.txt"
  cwd "/srv/pypi/src"
  action :nothing
end

mercurial "/srv/pypi/src" do
  repository "https://bitbucket.org/pypa/pypi"
  reference "tip"
  action :sync

  user "root"
  group node["pypi"]["group"]

  notifies :run, "execute[install requirements]"
end

data_dir = node["pypi"]["web"]["dirs"]["data"]
files_dir = node["pypi"]["web"]["dirs"]["files"]
docs_dir = node["pypi"]["web"]["dirs"]["docs"]
key_dir = node["pypi"]["web"]["dirs"]["key"]

template "/srv/pypi/config.ini" do
  source "pypi-config.ini.erb"
  variables ({
    :debug => node["pypi"]["web"]["debug"] ? "yes" : "no",
    :admins => node["pypi"]["admins"],
    :database => {
      :host => node["pypi"]["database"].fetch("hostname", database["hostname"]),
      :user => node["pypi"]["database"].fetch("user", database["user"]),
      :password => node["pypi"]["database"].fetch("password", database["password"]),
      :name => node["pypi"]["web"]["database"].fetch("name", database["database"]),
    },
    :dirs => {
      :data => data_dir,
      :files => files_dir.start_with?("/") ? files_dir : File.join(data_dir, files_dir),
      :docs => docs_dir.start_with?("/") ? docs_dir : File.join(data_dir, docs_dir),
      :key => key_dir.start_with?("/") ? key_dir : File.join(data_dir, key_dir),
    },
    :pubsubhubbub => node["pypi"]["web"]["pubsubhubbub"],
    :mail => {
      :host => node["pypi"]["web"]["mail"]["host"],
      :email => node["pypi"]["web"]["mail"]["email"],
      :reply => node["pypi"]["web"]["mail"]["reply"],
    },
    :urls => {
      :webui => node["pypi"]["web"]["urls"]["webui"],
      :files => node["pypi"]["web"]["urls"]["files"],
      :docs => node["pypi"]["web"]["urls"]["docs"],
      :python => node["pypi"]["web"]["urls"]["python"],
    },
    :scripts => {
      :simple => node["pypi"]["web"]["scripts"]["simple"],
      :simple_sign => node["pypi"]["web"]["scripts"]["simple_sign"],
    },
    :sshkeys_update => node["pypi"]["web"]["sshkeys_update"],
    :cheesecake_password => secrets["cheesecake_password"],
    :reset_secret => secrets["reset_secret"],
    :rss => {
      :pypi => node["pypi"]["web"]["rss"]["pypi"],
      :packages => node["pypi"]["web"]["rss"]["packages"],
    },
    :passlib => {
      :schemes => node["pypi"]["passlib"]["schemes"],
      :deprecated => node["pypi"]["passlib"]["deprecated"],
    },
    :sentry => {
      :dsn => secrets["sentry"]["dsn"],
    },
    :fastly => {
      :api_domain => node["pypi"]["fastly"]["api_domain"],
      :api_key => secrets["fastly"]["api_key"],
      :service_id => secrets["fastly"]["service_id"],
    },
  })
  user "root"
  group node["pypi"]["group"]
  mode "640"
end

file "/srv/pypi/src/pypi.wsgi" do
  mode "755"
end

directory "/srv/pypi/wsgi" do
  mode "750"
  user node["apache"]["user"]
  group node["apache"]["group"]
end

template "/srv/pypi/wsgi/pypi.wsgi" do
  source "pypi.wsgi.erb"
  variables ({
    :pypi_src => "/srv/pypi/src",
    :pypi_wsgi => "/srv/pypi/src/pypi.wsgi",
    :pypi_config => "/srv/pypi/config.ini",
  })

  user "www-data"
  group "www-data"
  mode "750"
end

web_app "pypi" do
  template "wsgi_web_app.conf.erb"

  server_name "pypi.python.org"
  server_aliases [node['hostname'], node['fqdn']]

  docroot "/srv/www/pypi.python.org"

  wsgi_root "/"
  wsgi_directory "/srv/pypi/wsgi"
  wsgi_script "/srv/pypi/wsgi/pypi.wsgi"
end
