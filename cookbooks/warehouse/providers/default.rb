use_inline_resources

action :install do

  # Default the virtualenv to a path based off of the main path
  virtualenv = new_resource.virtualenv.nil? ? ::File.join(new_resource.path, "env") : new_resource.virtualenv

  # Setup the environment that we'll use for commands and such
  environ = {
    "PYTHONPATH" => new_resource.path,
    "DJANGO_SETTINGS_MODULE" => "settings",
    "DJANGO_CONFIGURATION" => new_resource.debug ? "Development" : "Production",
  }
  environ.merge! new_resource.environment

  if new_resource.create_user
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
  end

  directory new_resource.path do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  gunicorn_config ::File.join(new_resource.path, "gunicorn.config.py") do
    owner new_resource.user
    group new_resource.group

    listen "unix:#{::File.join(new_resource.path, "warehouse.sock")}"

    action :create
    notifies :restart, "supervisor_service[#{new_resource.name}]"
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
      :installed_apps => new_resource.installed_apps,
    })

    notifies :restart, "supervisor_service[#{new_resource.name}]"
  end

  template ::File.join(new_resource.path, "envvars") do
    owner new_resource.user
    group new_resource.group
    mode "0750"
    backup false

    cookbook "warehouse"
    source "envvars.erb"

    variables :environment => environ
  end

  python_virtualenv virtualenv do
    interpreter "python3"
    owner new_resource.user
    group new_resource.group
    action :create
  end

  new_resource.packages.each do |pkg, version|
    python_pip pkg do
      virtualenv virtualenv

      unless version == :latest
        version version
      end

      action :upgrade
      notifies :restart, "supervisor_service[#{new_resource.name}]"
    end
  end

  python_pip "gunicorn" do
    virtualenv virtualenv

    action :upgrade
    notifies :restart, "supervisor_service[#{new_resource.name}]"
  end

  python_pip "warehouse" do
    version new_resource.version
    virtualenv virtualenv
    action :upgrade

    notifies :restart, "supervisor_service[#{new_resource.name}]"
    notifies :run, "execute[collectstatic]", :immediately
  end

  supervisor_service new_resource.name do
    command "#{::File.join(virtualenv, "bin", "gunicorn")} -c #{::File.join(new_resource.path, "gunicorn.config.py")} warehouse.wsgi"
    process_name new_resource.name
    directory new_resource.path
    environment environ
    user new_resource.user
    action :enable
  end

  execute "collectstatic" do
    command "#{::File.join(virtualenv, "bin", "warehouse")} collectstatic --noinput"
    cwd new_resource.path
    environment environ
    user new_resource.user
    group new_resource.group

    action :nothing
  end

  template "#{node['nginx']['dir']}/sites-available/#{new_resource.name}.warehouse.conf" do
    owner "root"
    group "root"
    mode "0755"
    backup false

    cookbook "warehouse"
    source "nginx.conf.erb"

    variables ({
      :resource => new_resource,
      :sock => ::File.join(new_resource.path, "warehouse.sock"),
      :name => "#{new_resource.name}-warehouse",
      :static_files => {
        "/static" => ::File.join(new_resource.path, "static"),
      }
    })

    notifies :reload, "service[nginx]"
  end

  nginx_site "#{new_resource.name}.warehouse.conf" do
    enable true
  end

  # Taken from the nginx cookbook so that we can restart Nginx
  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end
end
