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
      file '/home/rsnapshot/.ssh/authorized_keys' do
        owner 'rsnapshot'
        group 'rsnapshot'
        mode '644'
        content %Q{no-pty,no-agent-forwarding,no-X11-forwarding,no-port-forwarding,from="#{server['ipaddress']}" #{server['rsnapshot']['server_key']}}
      end
    end
  end
end
