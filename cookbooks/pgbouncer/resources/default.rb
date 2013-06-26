default_action :install

# Administrative settings
attribute :logfile, :kind_of => String, :default => '/var/log/postgresql/pgbouncer.log'
attribute :pidfile, :kind_of => String, :default => '/var/run/postgresql/pgbouncer.pid'
# Where to wait for clients
attribute :listen_addr, :kind_of => String, :default => '127.0.0.1'
attribute :listen_port, :kind_of => [String, Integer], :default => 5432
attribute :unix_socket_dir, :kind_of => String, :default => '/var/run/postgresql'
# Authentication settings
attribute :auth_type, :equal_to => %w{any trust plain crypt md5}, :default => 'md5'
attribute :auth_file, :kind_of => [String, NilClass], :default => '/etc/pgbouncer/users'
# Users allowed into database 'pgbouncer'
attribute :admin_users, :kind_of => [String, Array, NilClass]
attribute :stats_users, :kind_of => [String, Array, NilClass]
# Pooler personality questions
attribute :pool_mode, :equal_to => %w{session transaction statement}, :default => 'session'
attribute :server_reset_query, :kind_of => [String, NilClass], :default => 'DISCARD ALL;'
attribute :server_check_query, :kind_of => [String, NilClass], :default => 'SELECT 1;'
attribute :server_check_delay, :kind_of => [String, Integer], :default => 10
# Connection limits
attribute :max_client_conn, :kind_of => [String, Integer], :default => 100
attribute :default_pool_size, :kind_of => [String, Integer], :default => 40
