action :install do
  package 'rsnapshot' do
    action :upgrade
  end

  backups = []
  search(:node, 'rsnapshot_backups:*') do |node|
    node['rsnapshot_backups'].each do |directory, backup|
      backups['host'] = node['fqdn']
      backups << backup
    end
  end

  template "#{new_resource.dir}/rsnapshot.conf" do
    source 'rsnapshot.conf.erb'
    owner 'root'
    group 'root'
    mode '400'
    variables :server => new_resource, :backups => backups
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

  rsnapshot_client new_resource.name do
    server_role nil
  end

  execute "#{new_resource.name}: generate SSH key" do
    command 'ssh-keygen -t rsa -b 4096'
    user 'rsnapshot'
    not_if { ::File.exists?(::File.expand_path('~rsnapshot/.ssh/id_rsa')) rescue false }
  end

  ruby_block "#{new_resource.name}: read SSH key" do
    block do
      node.set['rsnapshot']['server_key'] = ::File.new(::File.expand_path('~rsnapshot/.ssh/id_rsa')).read
    end
  end
end

action :remove do
  raise 'later'
end
