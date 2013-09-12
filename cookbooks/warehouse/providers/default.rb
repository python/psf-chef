action :install do
  # Default the virtualenv to a path based off of the main path
  virtualenv = new_resource.virtualenv.nil? ? ::File.join(new_resource.path, "env") : new_resource.virtualenv

  # Setup the environment that we'll use for commands and such
  environ = {
    "DJANGO_SETTINGS_MODULE" => "settings",
    "DJANGO_CONFIGURATION" => new_resource.debug ? "Development" : "Production",
  }
  environ.merge new_resource.environment

  group new_resource.group do
    system true
  end

  user new_resource.user do
    comment "#{new_resource.name} Warehouse Service"
    gid new_resource.group
    system true
    shell '/bin/false'
    home new_resource.path
  end

  directory new_resource.path do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  directory ::File.join(new_resource.path, "config") do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  python_virtualenv virtualenv do
    interpreter "python3"
    owner new_resource.user
    group new_resource.group
    action :create
  end

  ["gunicorn"].each do |pkg|
    python_pip pkg do
      virtualenv virtualenv
      action :upgrade
    end
  end

  python_pip "warehouse" do
    version new_resource.version
    virtualenv virtualenv
    action :upgrade
  end

  gunicorn_config ::File.join(new_resource.path, "gunicorn.config.py") do
    owner new_resource.user
    group new_resource.group
    action :create
  end

  template ::File.join(new_resource.path, "settings.py") do
    owner new_resource.user
    group new_resource.group
    mode "0750"
    backup false

    cookbook "warehouse"
    source "settings.py.erb"

    variables ({
      :allowed_hosts => new_resource.domains,
      :secret_key => new_resource.secret_key,
      :static_root => ::File.join(new_resource.path, "static"),
      :database => new_resource.database,
    })
  end

  supervisor_service new_resource.name do
    command "#{::File.join(virtualenv, "bin", "gunicorn")} -c #{::File.join(new_resource.path, "gunicorn.config.py")} warehouse.wsgi"
    process_name new_resource.name
    directory new_resource.path
    environment environ
    user new_resource.user
    action :enable
  end
end
