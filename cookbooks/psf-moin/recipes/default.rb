include_recipe 'apache2'
include_recipe 'apache2::mod_wsgi'
include_recipe 'python'

python_virtualenv '/srv/moin' do
  action :create
  owner 'root'
  group 'root'
end

{
  'moin' => '1.9.6',
  'python-openid' => '2.2.5',
  'docutils' => '0.10',
}.each do |name, ver|
  python_pip name do
    action :upgrade
    version ver
    virtualenv '/srv/moin'
    user 'root'
    group 'root'
  end
end

group 'moin' do
  system true
end

user 'moin' do
  comment 'MoinMoin service'
  gid 'moin'
  system true
  shell '/bin/bash'
  home '/data/moin'
end

directory '/data' do
  owner 'root'
  group 'root'
  mode '755'
end

directory '/data/moin' do
  owner 'moin'
  group 'moin'
  mode '755'
end

directory '/data/www' do
  owner 'moin'
  group 'moin'
  mode '755'
end

# template "#{node['apache']['dir']}/sites-available/wiki.python.org.conf" do
#   source 'wiki.python.org.conf.erb'
#   owner 'root'
#   group 'root'
#   mode '644'
#   notifies :reload, 'service[apache2]'
# end

# apache_site 'wiki.python.org.conf'
# apache_site 'default' do
#   enable false
# end

# template '/srv/moin/moin.wsgi' do
#   source 'moin.wsgi.erb'
#   owner 'root'
#   group 'root'
#   mode '644'
#   notifies :reload, 'service[apache2]'
# end

# %w{moin jython psf moin-pycon}.each do |wiki|
#   execute "/srv/moin/bin/moin --config-dir=/data/moin/instances --wiki-url=http://wiki.python.org/#{wiki} maint cleancache" do
#     action :nothing
#     user 'moin'
#     group 'moin'
#     subscribes :run, 'python_pip[moin]'
#     notifies :reload, 'service[apache2]'
#   end
# end
