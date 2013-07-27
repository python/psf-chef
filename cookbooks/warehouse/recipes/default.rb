# Make sure git is installed
include_recipe "git"

# Make sure that the Postgresql Client library is installed
include_recipe "postgresql"

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

# Deploy Warehouse
application "warehouse" do
  path node["warehouse"]["path"]

  owner node["warehouse"]["user"]
  group node["warehouse"]["group"]

  repository node["warehouse"]["source"]["repository"]
  revision node["warehouse"]["source"]["revision"]

  migrate false

  django do
    local_settings_file "settings.py"
    settings_template "settings.py.erb"

    debug node["warehouse"]["debug"]

    settings ({
      :secret_key => secrets["warehouse"]["secret_key"],
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
    virtualenv File.join(node["warehouse"]["path"], "shared/env")

    port node["warehouse"]["conf"]["app"]["port"]

    environment ({
      "DJANGO_SETTINGS_MODULE" => "settings",
      "DJANGO_CONFIGURATION" => node["warehouse"]["conf"]["debug"] ? "Development" : "Production",
    })
  end

  nginx_load_balancer do
    hosts ["localhost"] if Chef::Config[:solo] # For testing in Vagrant
    application_server_role "pypi"

    server_name node["warehouse"]["domains"] + [node["fqdn"]]

    application_port node["warehouse"]["conf"]["app"]["port"]
  end
end
