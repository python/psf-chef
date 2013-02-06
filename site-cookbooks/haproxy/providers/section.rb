action :install do
  template "#{new_resource.haproxy_resource.config_directory}/conf.d/#{new_resource.name}.cfg" do
    source new_resource.source
    cookbook new_resource.cookbook || new_resource.cookbook_name.to_s
    owner 'root'
    group 'root'
    mode '644'
    variables new_resource.variables
    notifies :reload, new_resource.haproxy_resource
  end
end

action :remove do
  file "#{new_resource.haproxy_resource.config_directory}/conf.d/#{new_resource.name}.cfg" do
    action :delete
    notifies :reload, new_resource.haproxy_resource
  end
end
