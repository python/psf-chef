action :install do
  # Quickie argument validation
  write_count = [new_resource.write_ip, new_resource.write_proxy, new_resource.proxy_proxy].count{|val| val}
  raise 'At most one of write-ip, write-proxy, and proxy-proxy can be enabled' if write_count > 1

  package_file_name = "stud_#{new_resource.version}_amd64.deb"

  cookbook_file "#{Chef::Config[:file_cache_path]}/#{package_file_name}" do
    source package_file_name
    cookbook 'stud'
    owner 'root'
    group 'root'
    mode '644'
  end

  dpkg_package 'stud' do
    source "#{Chef::Config[:file_cache_path]}/#{package_file_name}"
  end

  template "/etc/init/#{new_resource.resource_name}.conf" do
    source 'upstart.conf.erb'
    owner 'root'
    group 'root'
    mode '644'
    variables :stud => new_resource
    notifies :restart, "service[#{new_resource.resource_name}]"
  end

  service new_resource.resource_name do
    action :enable
    provider Chef::Provider::Service::Upstart
    supports :status => true
  end

  directory '/etc/stud' do
    owner 'root'
    group 'root'
    mode '755'
  end

  template "/etc/stud/#{new_resource.name}.conf" do
    source new_resource.config_template || 'stud.conf.erb'
    cookbook new_resource.config_template ? new_resource.cookbook_name.to_s : 'stud'
    owner 'root'
    group 'root'
    mode '644'
    variables :stud => new_resource
    notifies :restart, "service[#{new_resource.resource_name}]"
  end

  service new_resource.resource_name do
    action :start
  end
end
