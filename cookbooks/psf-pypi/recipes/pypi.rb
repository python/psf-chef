# Make sure Nginx is installed
include_recipe "nginx"

directory '/var/run/pypi' do
  owner 'www-data'
end

# Install the pypi.python.org site
template "#{node['nginx']['dir']}/sites-available/pypi.conf" do
  source "nginx_pypi.conf.erb"

  owner "root"
  group "root"
  mode "644"

  variables ({
    :domains => [
        "pypi.python.org", "cheeseshop.python.org", "a.pypi.python.org",
        "b.pypi.python.org", "d.pypi.python.org", "g.pypi.python.org",
    ],
    :root_dir => "/data/www/pypi",
    :packages_dir => "/data/packages",
    :static_dir => "/data/pypi/static",
    :hsts_seconds => 31536000,
    :uwsgi_sock => "unix:/var/run/pypi/pypi.sock",
    :upload_size => "32M",
  })

  notifies :reload, resources(:service => 'nginx')
end

nginx_site "pypi.conf" do
  enable true
end

# Install the packages.python.org site
template "#{node['nginx']['dir']}/sites-available/packages.conf" do
  source "nginx_redirect.conf.erb"

  owner "root"
  group "root"
  mode "644"

  variables ({
    :existing_domain => "packages.python.org",
    :new_domain => "pythonhosted.org",
  })

  notifies :reload, resources(:service => 'nginx')
end

nginx_site "packages.conf" do
  enable true
end

# Install the pythonhosted.org site
template "#{node['nginx']['dir']}/sites-available/pythonhosted.conf" do
  source "nginx_static.conf.erb"

  owner "root"
  group "root"
  mode "644"

  variables ({
    :domain => "pythonhosted.org",
    :root_dir => "/data/packagedocs",
  })

  notifies :reload, resources(:service => 'nginx')
end

nginx_site "pythonhosted.conf" do
  enable true
end


# Disable the default site
nginx_site "default" do
  enable false
end
