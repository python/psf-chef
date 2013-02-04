include_recipe 'pgbouncer'

database = data_bag_item('secrets', 'postgres')['pypi']

pgbouncer_database database['database'] do
  host database['hostname']
  user database['user']
  password database['password']
end

pgbouncer_user database['user'] do
  password database['password']
end
