haproxy 'haproxy' do
  user node['haproxy']['user']
  group node['haproxy']['group']
  config_directory node['haproxy']['config_directory']
end

