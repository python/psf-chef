# Setup postgres locally for testing
db = data_bag_item("secrets", "postgres")["pycon2014"]

postgresql_database_user db['user'] do
  connection host: "127.0.0.1", port: 5432, username: 'postgres', password: node['postgresql']['password']['postgres']
  password db['password']
end

postgresql_database db['database'] do
  connection host: "127.0.0.1", port: 5432, username: 'postgres', password: node['postgresql']['password']['postgres']
  owner db['user']
end
