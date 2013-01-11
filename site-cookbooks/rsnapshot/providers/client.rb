action :install do
  group 'rsnapshot' do
    system true
  end

  user 'rsnapshot' do
    comment 'rsnapshot backup service'
    gid 'rsnapshot'
    system true
    shell '/bin/bash'
    home '/home/rsnapshot'
    supports :manage_home => true
  end

  directory '/home/rsnapshot/.ssh' do
    owner 'rsnapshot'
    group 'rsnapshot'
    mode '755'
  end

  if new_resource.server_role
    server = search(:node, "roles:#{new_resource.server_role}").first
    if server
      template '/home/rsnapshot/.ssh/authorized_keys' do
        cookbook 'user'
        source 'authorized_keys.erb'
        owner 'rsnapshot'
        group 'rsnapshot'
        mode '644'
        variables :user => 'rsnapshot', :ssh_keys => [server['rsnapshot']['server_key']]
      end
    end
  end
end
