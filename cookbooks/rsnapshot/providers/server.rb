action :install do
  package 'rsnapshot' do
    action :upgrade
  end

  backups = []
  search(:node, 'rsnapshot_backups:*') do |backup_node|
    backup_node['rsnapshot_backups'].each do |directory, backup|
      next if backup_node.name == node.name # For now just skip self
      backup = backup.to_hash
      backup['host'] = backup_node['fqdn']
      backup['directory'] << '/' unless backup['directory'].end_with?('/')
      backups << backup
    end
  end

  scripts = []
  run_context.resource_collection.each do |res|
    if res.is_a? Chef::Resource::RsnapshotScript
      scripts << res
    end
  end

  template "#{new_resource.dir}/rsnapshot.conf" do
    source 'rsnapshot.conf.erb'
    owner 'root'
    group 'root'
    mode '400'
    variables :server => new_resource, :backups => backups, :scripts => scripts
  end

  new_resource.retain.each do |ret|
    cron "rsnapshot-#{new_resource.name}-#{ret.name}" do
      minute ret.minute
      hour ret.hour
      day ret.day
      month ret.month
      weekday ret.weekday
      command "/usr/bin/rsnapshot #{ret.name}"
    end
  end

  # Just in case
  directory '/root/.ssh' do
    owner 'root'
    group 'root'
    mode '755'
  end

  execute "#{new_resource.name}: generate SSH key" do
    command 'ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsnapshot -N ""'
    user 'root'
    not_if { ::File.exists?('/root/.ssh/id_rsnapshot')}
  end

  ruby_block "#{new_resource.name}: read SSH key" do
    block do
      node.set['rsnapshot']['server_key'] = ::File.new('/root/.ssh/id_rsnapshot.pub').read
    end
  end
end

action :remove do
  raise 'later'
end
