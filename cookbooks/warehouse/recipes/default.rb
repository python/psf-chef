#
# The site uses Python 3.3, which we need to install from the "deadsnakes"
# PPA. This requires installing the PPA, then using it to install Python 3.3.
#
apt_repository "deadsnakes" do
  uri "http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "FF3997E83CD969B409FB24BC5BB92C09DB82666C"
end

package "python3.3-dev" do
  action :upgrade
end

# Make sure git is installed
include_recipe "git"

# Make sure that the Postgresql Client library is installed
include_recipe "postgresql"

# Make sure that virtualenv is installed
include_recipe "python::virtualenv"

# Setup User and Group
group node["warehouse"]["group"] do
  system true
end

user node["warehouse"]["user"] do
  system true
  gid node["warehouse"]["group"]
end

# Get our Database settings
database = data_bag_item("secrets", "postgres")["pypi"]

# Get our secrets
secrets = data_bag_item("secrets", "pypi")

# Work around the django target not understanding Python 3.3: as it turns out,
# the python_virtualenv resource (that the django application uses under the
# hood) doesn't check very hard that the virtualenv exists at any particular
# version. So we'll (ab)use that fact and create a Python 3.3 virtualenv; the
# django application provider will sorta silently pick that up and be happy.
[node["warehouse"]["path"], "#{node["warehouse"]["path"]}/shared"].each do |d|
  directory d do
    owner node["warehouse"]["user"]
    group node["warehouse"]["group"]

    action :create
  end
end

python_virtualenv "#{node["warehouse"]["path"]}/shared/env" do
  interpreter "python3.3"
  owner node["warehouse"]["user"]
  group node["warehouse"]["group"]

  action :create
end

# Deploy Warehouse
environment = {
  "DJANGO_SETTINGS_MODULE" => "settings",
  "DJANGO_CONFIGURATION" => node["warehouse"]["conf"]["debug"] ? "Development" : "Production",
}

application "warehouse" do
  path node["warehouse"]["path"]

  owner node["warehouse"]["user"]
  group node["warehouse"]["group"]

  repository node["warehouse"]["source"]["repository"]
  revision node["warehouse"]["source"]["revision"]

  symlinks ({
    "static" => "static",
  })

  migrate false

  django do
    local_settings_file "settings.py"
    settings_template "settings.py.erb"

    debug node["warehouse"]["debug"]

    settings ({
      :allowed_hosts => node["warehouse"]["domains"],
      :secret_key => secrets["warehouse"]["secret_key"],
      :static_root => File.join(node["warehouse"]["path"], "shared", "static"),
    })

    database do
      database database["database"]
      host database["hostname"]
      username database["user"]
      password database["password"]

      engine "postgresql_psycopg2"
    end
  end

  gunicorn do
    app_module node["warehouse"]["conf"]["app"]["wsgi"]
    virtualenv File.join(node["warehouse"]["path"], "shared", "env")

    port node["warehouse"]["conf"]["app"]["port"]

    environment environment
  end

  nginx_load_balancer do
    template "nginx.conf.rb"

    hosts ["localhost"] if Chef::Config[:solo] # For testing in Vagrant
    application_server_role "pypi"

    server_name node["warehouse"]["domains"]

    application_port node["warehouse"]["conf"]["app"]["port"]

    static_files ({
      "/static" => "static",
    })
  end

  before_symlink do
    warehouse_cmd = ::File.join(new_resource.path, "shared", "env", "bin", "warehouse")
    execute "#{warehouse_cmd} collectstatic --noinput" do
      user new_resource.owner
      group new_resource.group
      environment environment.merge({"PYTHONPATH" => new_resource.release_path})
      cwd new_resource.release_path
    end
  end
end
