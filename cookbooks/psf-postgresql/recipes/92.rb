cookbook_file '/etc/apt/preferences.d/pgdg.pref' do
  owner 'root'
  group 'root'
  mode '644'
  source 'pgdg.pref'
end

apt_repository 'pgdg' do
  uri 'http://apt.postgresql.org/pub/repos/apt/'
  arch 'amd64'
  distribution 'precise-pgdg'
  components ['main']
  key 'http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc'
end

package 'postgresql-9.2' do
  action :upgrade
end
