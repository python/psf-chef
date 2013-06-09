include_recipe 'pgbouncer'

db = data_bag_item("secrets", "postgres")["pypy-codespeed"]


pgbouncer_database db["database"] do
  host db["hostname"]
  user db["user"]
  password db["password"]
end

pgbouncer_user db["user"] do
  password db["password"]
end
