action :install do
  group 'postgres' do
    system true
  end

  user 'pgbouncer' do
    comment 'PgBouncer service'
    gid 'postgres'
    system true
    shell '/bin/false'
    home '/var/lib/postgresql'
  end

  package 'pgbouncer' do
    action :upgrade
  end

  execute '/etc/init.d/pgbouncer stop' do
    user 'root'
    only_if { ::File.exists? '/etc/init.d/pgbouncer' }
  end

  file '/etc/default/pgbouncer' do
    action :delete
  end

  file '/etc/init.d/pgbouncer' do
    action :delete
  end

  template '/etc/init/pgbouncer.conf' do
    source 'upstart.conf.erb'
    owner 'root'
    group 'root'
    mode '644'
    variables :pgbouncer => new_resource
    notifies :restart, 'service[pgbouncer]'
  end

  service 'pgbouncer' do
    action :enable
    provider Chef::Provider::Service::Upstart
    supports :reload => true, :status => true
  end

  directory '/etc/pgbouncer' do
    owner 'root'
    group 'root'
    mode '755'
  end

  template '/etc/pgbouncer/pgbouncer.ini' do
    source 'pgbouncer.ini.erb'
    owner 'root'
    group 'postgres'
    mode '640'
    notifies :reload, 'service[pgbouncer]'
    variables :pgbouncer => new_resource, :databases => run_context.resource_collection.select {|res| res.is_a? Chef::Resource::PgbouncerDatabase}
  end

  template '/etc/pgbouncer/users' do
    source 'users.erb'
    owner 'root'
    group 'postgres'
    mode '640'
    notifies :reload, 'service[pgbouncer]'
    variables :users => run_context.resource_collection.select {|res| res.is_a? Chef::Resource::PgbouncerUser}
  end

  service 'pgbouncer' do
    action :start
  end
end
