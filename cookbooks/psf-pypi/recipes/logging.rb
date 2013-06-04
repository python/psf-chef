template "/etc/rsyslog.d/25-pypi-logging.conf" do
  source "25-pypi-logging.conf.erb"
  backup false
  variables(
    :cdn => node["pypi"]["cdn"]["logging"],
  )

  owner "root"
  group "root"
  mode "644"

  notifies :restart, "service[#{node['rsyslog']['service_name']}]"
end
