include_recipe 'pgbouncer'

database = data_bag_item('secrets', 'postgres')

directory '/var/run/postgresql' do
  owner 'pgbouncer'
end

pgbouncer_database database['pypi']['database'] do
  host database['pypi']['hostname']
  user database['pypi']['user']
  password database['pypi']['password']
end

pgbouncer_user database['pypi']['user'] do
  password database['pypi']['password']
end
