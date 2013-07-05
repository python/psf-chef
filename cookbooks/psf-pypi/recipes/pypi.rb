database = data_bag_item("secrets", "postgres")["pypi"]
secrets = data_bag_item("secrets", "pypi")

data_dir = node["pypi"]["web"]["dirs"]["data"]
files_dir = File.expand_path(node["pypi"]["web"]["dirs"]["files"], data_dir)
docs_dir = File.expand_path(node["pypi"]["web"]["dirs"]["docs"], data_dir)
key_dir = File.expand_path(node["pypi"]["web"]["dirs"]["key"], data_dir)
stats_dir = File.expand_path(node["pypi"]["web"]["dirs"]["stats"], data_dir)
cache_dir = File.expand_path(node["pypi"]["web"]["dirs"]["cache"], data_dir)
static_dir = File.expand_path(node["pypi"]["web"]["dirs"]["static"], data_dir)

include_recipe "postgresql::client"
include_recipe "python"
include_recipe "mercurial"
include_recipe "supervisor"
include_recipe "nginx"

package "python-m2crypto" do end

# Create our user and group
group node["pypi"]["group"] do
  system true
end

user node["pypi"]["user"] do
  comment "Python Package Index"
  home node["pypi"]["home"]
  gid node["pypi"]["group"]
  system true
end

# Create the required directories
dirs = [
  node["pypi"]["home"],
  files_dir,
  docs_dir,
  key_dir,
  stats_dir,
  cache_dir,
]

dirs.each do |dir|
  directory dir do
    mode "755"
    user node["pypi"]["user"]
    group node["pypi"]["group"]
    recursive true
  end
end

# Create our VirtualEnv
python_virtualenv "#{node["pypi"]["home"]}/env" do
  owner node["pypi"]["user"]
  group node["pypi"]["group"]
  action :create
end

# Fixes trying to install M2Crypto via PIP on Ubuntu
link "#{node["pypi"]["home"]}/env/lib/python2.7/site-packages/M2Crypto" do
  to "/usr/lib/python2.7/dist-packages/M2Crypto"
  owner node["pypi"]["user"]
end
link "#{node["pypi"]["home"]}/env/lib/python2.7/site-packages/M2Crypto-0.21.1.egg-info" do
  to "/usr/lib/python2.7/dist-packages/M2Crypto-0.21.1.egg-info"
  owner node["pypi"]["user"]
end

# Grab the PyPI code from the repository
mercurial "#{node["pypi"]["home"]}/src" do
  repository node["pypi"]["code"]["repository"]
  reference node["pypi"]["code"]["reference"]

  user node["pypi"]["user"]
  group node["pypi"]["group"]

  action :sync
  notifies :install, "python_pip[-r #{node["pypi"]["home"]}/src/requirements.txt]", :immediately
  notifies :restart, "supervisor_service[pypi]", :delayed
end

python_pip "-r #{node["pypi"]["home"]}/src/requirements.txt" do
  virtualenv "#{node["pypi"]["home"]}/env"

  user node["pypi"]["user"]
  group node["pypi"]["group"]

  action :nothing
end

link static_dir do
  to "#{node["pypi"]["home"]}/src/static"
  owner node["pypi"]["user"]
end

template "#{node["pypi"]["home"]}/config.ini" do
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
      :files => files_dir,
      :docs => docs_dir,
      :key => key_dir,
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
      :pypi => File.join(cache_dir, "pypi_rss.xml"),
      :packages => File.join(cache_dir, "pypi_packages_rss.xml"),
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
    :raw_package_prefix => node["pypi"]["web"]["package_internal_url"],
  })
  user node["pypi"]["user"]
  group node["pypi"]["group"]
  mode "640"

  notifies :restart, "supervisor_service[pypi]", :delayed
end

# Install the Private and Public Key
file "#{key_dir}/privkey" do
  content secrets["keys"]["private"]

  user node["pypi"]["user"]
  group node["pypi"]["group"]
  mode "600"

  notifies :restart, "supervisor_service[pypi]", :delayed
end

file "#{key_dir}/pubkey" do
  content secrets["keys"]["public"]

  user node["pypi"]["user"]
  group node["pypi"]["group"]
  mode "644"

  notifies :restart, "supervisor_service[pypi]", :delayed
end

# We need to make a wsgi.py that "redirects" to pypi.wsgi
template "#{node["pypi"]["home"]}/wsgi.py" do
  source "pypi-wsgi.py.erb"

  user node["pypi"]["user"]
  group node["pypi"]["group"]
  mode "750"

  variables ({
    :src_dir => "#{node["pypi"]["home"]}/src/",
    :wsgi_file => "#{node["pypi"]["home"]}/src/pypi.wsgi",
  })

  notifies :restart, "supervisor_service[pypi]", :delayed
end

# Install Gunicorn to serve PyPI
python_pip "gunicorn" do
  virtualenv "#{node["pypi"]["home"]}/env"

  user node["pypi"]["user"]
  group node["pypi"]["group"]

  action :install
  notifies :restart, "supervisor_service[pypi]", :delayed
end

# Configure gunicorn
gunicorn_config "#{node["pypi"]["home"]}/gunicorn.conf.py" do
  # PyPI *MUST* be run with sync, bad things happen otherwise
  worker_class "sync"

  worker_processes node["pypi"]["gunicorn"]["processes"]
  worker_timeout node["pypi"]["gunicorn"]["timeout"]

  owner node["pypi"]["user"]
  group node["pypi"]["group"]

  action :create
  notifies :restart, "supervisor_service[pypi]", :delayed
end

# Launch Gunciorn with Supervisor
supervisor_service "pypi" do
  command "#{node["pypi"]["home"]}/env/bin/gunicorn wsgi -c #{node["pypi"]["home"]}/gunicorn.conf.py"

  autostart true
  autorestart :unexpected
  user node["pypi"]["user"]
  environment :PYPI_CONFIG => "#{node["pypi"]["home"]}/config.ini"
  directory node["pypi"]["home"]
end

# Create an nginx config to serve PyPI
template "#{node["nginx"]["dir"]}/sites-available/pypi.python.org" do
  source "nginx-pypi.python.org.erb"
  mode "640"

  variables ({
    :domains => node["pypi"]["web"]["domains"],
    :static_root => static_dir,
    :stats_root => stats_dir,
    :package_root => files_dir,
    :serverkey => File.join(key_dir, "pubkey"),
    :hsts_seconds => node["pypi"]["web"]["hsts_seconds"],
    :package_internal_url => node["pypi"]["web"]["package_internal_url"],
    :max_body_size => node["pypi"]["web"]["max_body_size"],
  })

  notifies :reload, "service[nginx]", :delayed
end

# Enable the nginx site
nginx_site "pypi.python.org" do end
