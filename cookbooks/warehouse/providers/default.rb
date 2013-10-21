use_inline_resources

action :install do

  # Default the virtualenv to a path based off of the main path
  virtualenv = new_resource.virtualenv.nil? ? new_resource.path : new_resource.virtualenv

  # Setup the environment that we'll use for commands and such
  environ = {
    "PATH" => "#{virtualenv}/bin",
    "PYTHONPATH" => "#{new_resource.path}/var/pypi",
    "WAREHOUSE_CONF" => "#{new_resource.path}/etc/config.yml",
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

  directory "#{new_resource.path}/etc" do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  directory "#{new_resource.path}/var" do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  directory "#{new_resource.path}/var/pypi" do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  directory "#{new_resource.path}/var/www" do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    action :create
  end

  # Create our envdir for use with the ``envdir`` program
  directory "#{new_resource.path}/envars" do
    owner new_resource.user
    group new_resource.group
    mode "0750"
    action :create
  end

  # Create our envdir files
  environ.each do |k, v|
    file "#{new_resource.path}/envars/#{k}" do
      owner new_resource.user
      group new_resource.group
      mode "0750"
      content v
      action :create
    end
  end

  gunicorn_config "#{new_resource.path}/etc/gunicorn.config.py" do
    owner new_resource.user
    group new_resource.group

    listen "unix:#{new_resource.path}/var/warehouse.sock"

    action :create
    notifies :restart, "supervisor_service[#{new_resource.name}]", :immediately
  end

  file "#{new_resource.path}/etc/config.yml" do
    owner new_resource.user
    group new_resource.group
    mode "0750"
    backup false

    content ({
      "debug" => new_resource.debug,
      "site" => {
        "name" => new_resource.site_name,
      },
      "database" => {
        "url" => new_resource.database,
      },
      "redis" => {
        "url" => new_resource.redis,
      },
      "assets" => {
        "directory" => "#{new_resource.path}/var/www"
      },
      "urls" => new_resource.urls,
      "paths" => new_resource.paths,
      "cache" => new_resource.cache,
      "fastly" => new_resource.fastly,
    }.to_yaml)
  end

  python_virtualenv virtualenv do
    interpreter new_resource.python
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
      notifies :restart, "supervisor_service[#{new_resource.name}]", :immediately
    end
  end

  ["bcrypt", "gunicorn"].each do |pkg|
    python_pip pkg do
      virtualenv virtualenv
      action :upgrade
      notifies :restart, "supervisor_service[#{new_resource.name}]", :immediately
    end
  end

  python_pip "warehouse" do
    version new_resource.version
    virtualenv virtualenv
    action :upgrade

    notifies :restart, "supervisor_service[#{new_resource.name}]", :immediately
  end

  template "#{new_resource.path}/var/pypi/pypi_wsgi.py" do
    owner new_resource.user
    group new_resource.group
    mode "0755"
    backup false

    cookbook "warehouse"
    source "pypi_wsgi.py.erb"
  end

  supervisor_service new_resource.name do
    command "#{virtualenv}/bin/gunicorn -c #{new_resource.path}/etc/gunicorn.config.py pypi_wsgi"
    process_name new_resource.name
    directory new_resource.path
    environment environ
    user new_resource.user
    action :enable
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
      :sock => "#{new_resource.path}/var/warehouse.sock",
      :name => "#{new_resource.name}-warehouse",
    })

    notifies :reload, "service[nginx]", :immediately
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
