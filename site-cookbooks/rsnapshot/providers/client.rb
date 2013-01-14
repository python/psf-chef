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

  cookbook_file '/usr/local/bin/rsnapshot-rsync.py' do
    source 'rsync.py'
    owner 'root'
    group 'root'
    mode '755'
  end

  directory '/home/rsnapshot/.ssh' do
    owner 'rsnapshot'
    group 'rsnapshot'
    mode '755'
  end

  if new_resource.server_role
    server = search(:node, "roles:#{new_resource.server_role}").first
    if server
      file '/home/rsnapshot/.ssh/authorized_keys' do
        owner 'rsnapshot'
        group 'rsnapshot'
        mode '644'
        content %Q{no-pty,no-agent-forwarding,no-X11-forwarding,no-port-forwarding,from="#{server['ipaddress']}",command="sudo /usr/local/bin/rsnapshot-rsync.py" #{server['rsnapshot']['server_key']}}
      end
    else
      file '/home/rsnapshot/.ssh/authorized_keys' do
        action :delete
      end
    end
  else
    file '/home/rsnapshot/.ssh/authorized_keys' do
      action :delete
    end
  end

  sudo new_resource.name do
    template 'sudoers.erb'
  end
end
